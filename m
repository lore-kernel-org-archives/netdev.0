From: Bernard Pidoux F6BVP <f6bvp@free.fr>
Subject: kernel panic linux-2.6.27-rc7
Date: Sun, 28 Sep 2008 14:49:21 +0200
Message-ID: <48DF7D51.1010507@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: Jarek Poplawski <jarkao2@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g19.free.fr ([212.27.42.28]:48106 "EHLO smtp2-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751957AbYI1Mt0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Sep 2008 08:49:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Here is another report catched via netconsole.
Kernel is linux-2.6.27-rc7
kernel panic occurs within less than a minute after boot.


------------------------------
dim sep 28 14:38:59 CEST 2008
------------------------------
BUG: unable to handle kernel paging request at 6b6b6b73
IP: [<c0254689>] datagram_poll+0xd9/0xf0
*pde = 00000000
Oops: 0002 [#1]
Modules linked in: netrom rose mkiss crc16 ax25 netconsole configfs nfsd 
exportfs nfs lockd nfs_acl sunrpc af_packet snd_seq_dummy ipv6 
snd_seq_oss snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss 
binfmt_misc loop usb_storage scsi_mod floppy usbhid snd_ens1371 
snd_rawmidi snd_seq_device snd_ac97_codec uhci_hcd snd_pcm snd_timer snd 
soundcore snd_page_alloc usbcore ac97_bus intel_agp ide_cd_mod ne2k_pci 
agpgart 8390 ext3 jbd ide_disk piix ide_core [last unloaded: nf_conntrack]

Pid: 3672, comm: fpad Not tainted (2.6.27-rc7 #2)
EIP: 0060:[<c0254689>] EFLAGS: 00010202 CPU: 0
EIP is at datagram_poll+0xd9/0xf0
EAX: 6b6b6b6b EBX: c4470160 ECX: 00002059 EDX: 00002018
ESI: 00000001 EDI: 0000000c EBP: c67fdb3c ESP: c67fdb34
  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
Process fpad (pid: 3672, ti=c67fc000 task=c7998350 task.ti=c67fc000)
Stack: c8cc7300 c6bc27c0 c67fdb48 c024ab92 00001000 c67fde14 c017e495 
00000002
        00000001 00000000 c017e180 00000000 c67fdbc4 c67fdf9c c67fdf48 
00000000
        0000000d c67fde54 c67fde58 c67fde5c c67fde4c c67fde50 c67fde54 
00001bc0
Call Trace:
  [<c024ab92>] ? sock_poll+0x12/0x20
  [<c017e495>] ? do_select+0x315/0x5a0
  [<c017e180>] ? do_select+0x0/0x5a0
  [<c017ec80>] ? __pollwait+0x0/0xd0
  [<c0117fa0>] ? default_wake_function+0x0/0x10
  [<c0117fa0>] ? default_wake_function+0x0/0x10
  [<c0117fa0>] ? default_wake_function+0x0/0x10
  [<c0117fa0>] ? default_wake_function+0x0/0x10
  [<c0117fa0>] ? default_wake_function+0x0/0x10
  [<c0117fa0>] ? default_wake_function+0x0/0x10
  [<c013b8eb>] ? trace_hardirqs_off+0xb/0x10
  [<c012e3fb>] ? __kernel_text_address+0x1b/0x30
  [<c0104c9b>] ? dump_trace+0xbb/0x110
  [<c010b5ab>] ? save_stack_trace+0x2b/0x50
  [<c013b73c>] ? save_trace+0x3c/0xa0
  [<c013b7dd>] ? add_lock_to_list+0x3d/0xb0
  [<c013d9f2>] ? check_noncircular+0x12/0x110
  [<c01263a5>] ? lock_timer_base+0x25/0x50
  [<c013fb33>] ? validate_chain+0xb13/0xea0
  [<c01263a5>] ? lock_timer_base+0x25/0x50
  [<c013f0dc>] ? validate_chain+0xbc/0xea0
  [<c013f0dc>] ? validate_chain+0xbc/0xea0
  [<c014023c>] ? __lock_acquire+0x37c/0x9b0
  [<c013b8eb>] ? trace_hardirqs_off+0xb/0x10
  [<c017e90a>] ? core_sys_select+0x1ea/0x330
  [<c017e74d>] ? core_sys_select+0x2d/0x330
  [<c013e9db>] ? trace_hardirqs_on+0xb/0x10
  [<c8cc40fb>] ? ax25_ioctl+0xbb/0x690 [ax25]
  [<c8cc5c17>] ? ax25_connect+0x1e7/0x470 [ax25]
  [<c024deff>] ? release_sock+0xbf/0xd0
  [<c01e6146>] ? copy_from_user+0x46/0x80
  [<c024b871>] ? sys_connect+0x91/0xb0
  [<c8bdc9c4>] ? rose_ioctl+0x194/0x2c0 [rose]
  [<c024b105>] ? sock_ioctl+0x55/0x220
  [<c017ee1b>] ? sys_select+0xcb/0x190
  [<c01e5d04>] ? trace_hardirqs_on_thunk+0xc/0x10
  [<c0103bbd>] ? sysenter_do_call+0x12/0x35
  =======================
Code: b6 43 02 89 ca 83 ca 10 3c 07 0f b6 43 02 0f 44 ca 3c 02 74 d7 8b 
83 c8 00 00 00 d1 f8 39 83 c0 00 00 00 7c c1 8b 83 28 02 00 00 <80> 48 
08 01 5b 89 c8 5e 5d c3 b9 08 00 00 00 e9 53 ff ff ff 8d
EIP: [<c0254689>] datagram_poll+0xd9/0xf0 SS:ESP 0068:c67fdb34
Kernel panic - not syncing: Fatal exception
Rebooting in 60 seconds..

Regards,

Bernard




 >On 07-09-2008 14:53, Bernard Pidoux wrote:
 > Hi,
 >
 > I observed this message recently on a system with acpi=off for
 > the bios is quite old.
 >
 > Apparently listen application and console are involved.
 >
 > Is there anything I can try to resolve this situation ,
 >
 >
 > =================================
 > [ INFO: inconsistent lock state ]
 > 2.6.25.10-patched-ax25 #1
 > ---------------------------------
 > inconsistent {in-softirq-W} -> {softirq-on-W} usage.
 > listen/7202 [HC0[0]:SC0[0]:HE1:SE1] takes:
 >  (_xmit_ETHER){-+..}, at: [<c0262f08>] netpoll_send_skb+0x118/0x180

 >Hi Bernard,
 >
 >These warnings usually mean there is some local_irq_disable/enable()
 >instead of local_irq_save/restore() etc. on the xmit path (maybe in a
 >network driver used for netconsole). Anyway, as usual, it would be
 >nice to test it with some more current kernel, and if it's still
 >there, add some info about this driver and additional patches.
 >
 >Thanks,
 >Jarek P.
