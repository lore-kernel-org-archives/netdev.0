From: Lukas Tribus <luky-37@hotmail.com>
Subject: RE: tainted warnings with tcp splicing in 3.7.1
Date: Wed, 9 Jan 2013 15:50:01 +0100
Message-ID: <DUB107-W5763CF0DBFD588719D246DED2B0@phx.gbl>
References: <F476A81A60AA6B458C3DA58B993EA70A1B8F394A@MUCR10053060111.muc.traviangames.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dub0-omc1-s1.dub0.hotmail.com ([157.55.0.200]:26942 "EHLO
	dub0-omc1-s1.dub0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756339Ab3AIO4T convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2013 09:56:19 -0500
In-Reply-To: <F476A81A60AA6B458C3DA58B993EA70A1B8F394A@MUCR10053060111.muc.traviangames.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


=46or the record:
Another user reported similar warnings in a 3.5.0 kernel back in Septem=
ber [1] on the haproxy mailing list with the following kernel warnings:

[142654.793193] ------------[ cut here ]------------
[142654.793395] WARNING: at net/ipv4/tcp.c:1301 tcp_cleanup_rbuf+0x54/0=
x150()
[142654.793972] Hardware name: System Product Name
[142654.794573] cleanup rbuf bug: copied 68D1EF11 seq 68CFF65F rcvnxt 6=
8D3565D
[142654.795165] Modules linked in: ixgbe(O) binfmt_misc 8021q fcoe
garp stp llc libfcoe libfc scsi_transport_fc scsi_tgt ip6t_REJECT nf
_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter
ip6_tables snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_intel
snd_hda_codec nouveau snd_hwdep igb snd_seq snd_seq_device snd_pcm
eeepc_wmi asus_wmi ttm drm_kms_helper sparse_keymap snd_timer snd drm
coretemp rfkill i2c_algo_bit mxm_wmi wmi video lpc_ich mfd_core
crc32c_intel r8169 i2c_i801 i2c_core soundcore snd_page_alloc mii mdio
pcspkr serio_raw ghash_clmulni_intel microcode uinput [last unloaded:
ixgbe]
[142654.798215] Pid: 18374, comm: haproxy Tainted: G =A0 =A0 =A0 =A0W =A0=
O 3.5.0 #1
[142654.798838] Call Trace:
[142654.799440] =A0[<ffffffff810422cf>] warn_slowpath_common+0x7f/0xc0
[142654.800031] =A0[<ffffffff810423c6>] warn_slowpath_fmt+0x46/0x50
[142654.800653] =A0[<ffffffff8147c270>] ? sock_pipe_buf_release+0x20/0x=
20
[142654.801237] =A0[<ffffffff814cf294>] tcp_cleanup_rbuf+0x54/0x150
[142654.801847] =A0[<ffffffff814d0ae1>] tcp_read_sock+0x1b1/0x200
[142654.802440] =A0[<ffffffff81472777>] ? sock_sendpage+0x27/0x30
[142654.803037] =A0[<ffffffff814ccd60>] ? tcp_done+0x90/0x90
[142654.803644] =A0[<ffffffff814d0bf0>] tcp_splice_read+0xc0/0x250
[142654.804239] =A0[<ffffffff814726b2>] sock_splice_read+0x62/0x80
[142654.804843] =A0[<ffffffff8118c73b>] do_splice_to+0x7b/0xa0
[142654.805457] =A0[<ffffffff8118e850>] sys_splice+0x540/0x560
[142654.806040] =A0[<ffffffff8159aed2>] system_call_fastpath+0x16/0x1b
[142654.806646] ---[ end trace 46d7fb693af33fde ]---



[1] http://permalink.gmane.org/gmane.comp.web.haproxy/9559 		 	   		  -=
