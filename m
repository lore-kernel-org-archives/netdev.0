From: Bernard Pidoux F6BVP <f6bvp@free.fr>
Subject: [BUG] [ROSE] [AX25] system impossible to reboot with linux-2.6.24-rc5
Date: Mon, 17 Dec 2007 11:31:01 +0100
Message-ID: <47664FE5.9000601@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Jarek Poplawski <jarkao2@o2.pl>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Ralf Baechle DL5RB <ralf@linux-mips.org>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postfix2-g20.free.fr ([212.27.60.43]:37901 "EHLO
	postfix2-g20.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760815AbXLQKdp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 05:33:45 -0500
Received: from smtp5-g19.free.fr (smtp5-g19.free.fr [212.27.42.35])
	by postfix2-g20.free.fr (Postfix) with ESMTP id 283A921457D9
	for <netdev@vger.kernel.org>; Mon, 17 Dec 2007 09:32:57 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am running a packet switch application using AX25, mkiss and ROSE=20
modules (FPAC).
It runs for days without problems when the patch I recently sent to thi=
s=20
list are applied.

However, if I try to shutdown linux-2.6.24-rc5 it goes into an infinite=
=20
loop displaying the following message again and again and I cannot stop=
=20
it nor end the reboot unless hard resetting.
I took a picture of the screen at this time showing :

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
__delay+0x6/0x7
_raw_spin_lock=B00x7a/0xd2
ax25_find_cb+0x18/0xc6 [ax25]
ax25_send_frame+0x40/0x31 [ax25]
rose_send_frame+0x47/0x58 [rose]
rose_transmit_clear_request+0xae/0xc8 [rose]
rose_del_route_by_neigh+0x7e/0xbb [rose]
rose_link_failed+0x31/0x44 [rose]
ax25_link_failed+0x28/0x39 [ax25]
ax25_disconnect+0x34/0xbe [ax25]
ax25_device_event+0x5f/0x90 [ax25]
notifier_call_chain+0x2a/0x47
raw_notifier_call_chain+0x17/0x1a
dev_close+0x54/0x58
rollback_registered+0x9b/0x11d
unregister_netdevice+0x8/0x3d
unregister_netdev+0xf/0x15
mkiss_close+0x63/0x7c [mkiss]
release_dev+0x4ed/0x5a2
__lock_acquire+0xb9e/0xbe6
__lock_acquire+0xb9e/0xbe6
_atomic_dec_and_lock+0x22/0x2c
tty_release+0x7/0xa
__fput+0xbc/0x16b
filp_close+0x51/0x58
put_files_struct+0x5f/0xa7
do_exit+0x205/0x674
error_code+0x6a/0x70
sys_exit_group+0x0/0xd
sysenter_past_esp+0x5f/0x9a
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

Bernard Pidoux



