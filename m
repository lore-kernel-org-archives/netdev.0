From: Rolf Eike Beer <eike-kernel@sf-tec.de>
Subject: [BUG] stacktrace from skb_checksum_help() and skb_gso_segment()
Date: Wed, 26 Jul 2006 08:41:48 +0200
Message-ID: <200607260841.54017.eike-kernel@sf-tec.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1192756.VqL6tbdyTK";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sf-mail.de ([62.27.20.61]:17608 "EHLO mail.sf-mail.de")
	by vger.kernel.org with ESMTP id S1030403AbWGZGj6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 02:39:58 -0400
Received: from  ([::ffff:212.65.3.74] HELO siso-eb-i34d.silicon-software.de) (auth=eike-kernel@sf-tec.de)
	by mail.sf-mail.de (Qsmtpd 0.9) with (DHE-RSA-AES256-SHA encrypted) ESMTPSA
	for <netdev@vger.kernel.org>; Wed, 26 Jul 2006 08:39:56 +0200
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1192756.VqL6tbdyTK
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

linux-2.6 git tree from yesterday.

Before this the sky2 network driver was working. After a pseudo hotplug of =
the=20
device it was working again (at least if you receive this mail *g*).

What next?

Eike

Jul 26 08:22:51 siso-eb-i34d kernel: BUG: warning=20
at /home/beer/repos/linux-2.6/net/core/dev.c:1171/skb_checksum_help()
Jul 26 08:22:51 siso-eb-i34d kernel:  [<c1003aa9>]=20
show_trace_log_lvl+0x54/0xfd
Jul 26 08:22:51 siso-eb-i34d kernel:  [<c1004915>] show_trace+0xd/0x10
Jul 26 08:22:51 siso-eb-i34d kernel:  [<c100492f>] dump_stack+0x17/0x1c
Jul 26 08:22:51 siso-eb-i34d kernel:  [<c11a1c92>]=20
skb_checksum_help+0x55/0x108
Jul 26 08:22:51 siso-eb-i34d kernel:  [<f0953303>] ip_nat_fn+0x43/0x183=20
[iptable_nat]
Jul 26 08:22:51 siso-eb-i34d kernel:  [<f0953665>] ip_nat_local_fn+0x36/0xb=
5=20
[iptable_nat]
Jul 26 08:22:51 siso-eb-i34d kernel:  [<c11b043c>] nf_iterate+0x2e/0x61
Jul 26 08:22:51 siso-eb-i34d kernel:  [<c11b04a6>] nf_hook_slow+0x37/0x95
Jul 26 08:22:51 siso-eb-i34d kernel:  [<c11bb212>] ip_queue_xmit+0x362/0x3b2
Jul 26 08:22:51 siso-eb-i34d kernel:  [<c11c8cd2>]=20
tcp_transmit_skb+0x5f3/0x615
Jul 26 08:22:51 siso-eb-i34d kernel:  [<c11ca1b6>] tcp_push_one+0xb7/0xda
Jul 26 08:22:51 siso-eb-i34d kernel:  [<c11c1cc2>] tcp_sendmsg+0x786/0x990
Jul 26 08:22:51 siso-eb-i34d kernel:  [<c11d847c>] inet_sendmsg+0x39/0x46
Jul 26 08:22:51 siso-eb-i34d kernel:  [<c1199ac7>] do_sock_write+0x93/0x9b
Jul 26 08:22:51 siso-eb-i34d kernel:  [<c119a092>] sock_aio_write+0x56/0x64
Jul 26 08:22:51 siso-eb-i34d kernel:  [<c10584e6>] do_sync_write+0xaf/0xe4
Jul 26 08:22:51 siso-eb-i34d kernel:  [<c105889f>] vfs_write+0x94/0xe8
Jul 26 08:22:51 siso-eb-i34d kernel:  [<c105900c>] sys_write+0x3b/0x60
Jul 26 08:22:51 siso-eb-i34d kernel:  [<c1002845>] sysenter_past_esp+0x56/0=
x8d
Jul 26 08:22:51 siso-eb-i34d kernel: BUG: warning=20
at /home/beer/repos/linux-2.6/net/core/dev.c:1225/skb_gso_segment()
Jul 26 08:22:51 siso-eb-i34d kernel:  [<c1003aa9>]=20
show_trace_log_lvl+0x54/0xfd
Jul 26 08:22:51 siso-eb-i34d kernel:  [<c1004915>] show_trace+0xd/0x10
Jul 26 08:22:51 siso-eb-i34d kernel:  [<c100492f>] dump_stack+0x17/0x1c
Jul 26 08:22:51 siso-eb-i34d kernel:  [<c11a309b>] skb_gso_segment+0x84/0x1=
71
Jul 26 08:22:51 siso-eb-i34d kernel:  [<c11a4427>]=20
dev_hard_start_xmit+0x175/0x202
Jul 26 08:22:51 siso-eb-i34d kernel:  [<c11ad119>] __qdisc_run+0xde/0x1a5
Jul 26 08:22:51 siso-eb-i34d kernel:  [<c11a45ef>] dev_queue_xmit+0x13b/0x2=
4c
Jul 26 08:22:51 siso-eb-i34d kernel:  [<c11a9080>]=20
neigh_resolve_output+0x1cf/0x1fb
Jul 26 08:22:51 siso-eb-i34d kernel:  [<c11bb88d>] ip_output+0x1c4/0x1ff
Jul 26 08:22:51 siso-eb-i34d kernel:  [<c11bb223>] ip_queue_xmit+0x373/0x3b2
Jul 26 08:22:51 siso-eb-i34d kernel:  [<c11c8cd2>]=20
tcp_transmit_skb+0x5f3/0x615
Jul 26 08:22:51 siso-eb-i34d kernel:  [<c11ca1b6>] tcp_push_one+0xb7/0xda
Jul 26 08:22:51 siso-eb-i34d kernel:  [<c11c1cc2>] tcp_sendmsg+0x786/0x990
Jul 26 08:22:51 siso-eb-i34d kernel:  [<c11d847c>] inet_sendmsg+0x39/0x46
Jul 26 08:22:51 siso-eb-i34d kernel:  [<c1199ac7>] do_sock_write+0x93/0x9b
Jul 26 08:22:51 siso-eb-i34d kernel:  [<c119a092>] sock_aio_write+0x56/0x64
Jul 26 08:22:51 siso-eb-i34d kernel:  [<c10584e6>] do_sync_write+0xaf/0xe4
Jul 26 08:22:51 siso-eb-i34d kernel:  [<c105889f>] vfs_write+0x94/0xe8
Jul 26 08:22:51 siso-eb-i34d kernel:  [<c105900c>] sys_write+0x3b/0x60
Jul 26 08:22:51 siso-eb-i34d kernel:  [<c1002845>] sysenter_past_esp+0x56/0=
x8d

--nextPart1192756.VqL6tbdyTK
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBExw6yXKSJPmm5/E4RAmc3AJ0QNOQtq2HF9PQR7qnXGZBMNfByHQCfTUK1
UHxXnM+HcwjrWrccjI8SdB0=
=RqDC
-----END PGP SIGNATURE-----

--nextPart1192756.VqL6tbdyTK--
