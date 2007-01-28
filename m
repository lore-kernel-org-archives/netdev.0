From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: Re: 2.6.20-rc6-mm1
Date: Sun, 28 Jan 2007 23:31:00 +0100
Message-ID: <45BD2424.7020604@googlemail.com>
References: <20070127234928.64d8e437.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@osdl.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932925AbXA1WbP@vger.kernel.org>
In-Reply-To: <20070127234928.64d8e437.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton napisa=C5=82(a):
> Temporarily at
>=20
> 	http://userweb.kernel.org/~akpm/2.6.20-rc6-mm1/
>=20
> will appear one day at
>=20
> 	ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.20=
-rc6/2.6.20-rc6-mm1/
>=20
>=20

Jan 28 22:58:29 euridica kernel: BUG: using smp_processor_id() in preem=
ptible [00000001] code: yum-updatesd/2846
Jan 28 22:58:29 euridica kernel: caller is nf_conntrack_in+0x363/0x47f =
[nf_conntrack]
Jan 28 22:58:29 euridica kernel:  [<c01053c6>] show_trace_log_lvl+0x1a/=
0x2f
Jan 28 22:58:29 euridica kernel:  [<c0105ad6>] show_trace+0x12/0x14
Jan 28 22:58:29 euridica kernel:  [<c0105b98>] dump_stack+0x16/0x18
Jan 28 22:58:29 euridica kernel:  [<c0207803>] debug_smp_processor_id+0=
xb3/0xc8
Jan 28 22:58:29 euridica kernel:  [<fdbf8ad0>] nf_conntrack_in+0x363/0x=
47f [nf_conntrack]
Jan 28 22:58:29 euridica kernel:  [<fd9c32c4>] ipv4_conntrack_local+0x5=
3/0x5b [nf_conntrack_ipv4]
Jan 28 22:58:29 euridica kernel:  [<c02f2286>] nf_iterate+0x36/0x67
Jan 28 22:58:29 euridica kernel:  [<c02f241b>] nf_hook_slow+0x52/0xbe
Jan 28 22:58:29 euridica kernel:  [<c02fd280>] ip_queue_xmit+0x3d1/0x42=
0
Jan 28 22:58:29 euridica kernel:  [<c030b9b9>] tcp_transmit_skb+0x78b/0=
x7ca
Jan 28 22:58:29 euridica kernel:  [<c030d452>] __tcp_push_pending_frame=
s+0x732/0x811
Jan 28 22:58:29 euridica kernel:  [<c030e3de>] tcp_send_fin+0x146/0x150
Jan 28 22:58:29 euridica kernel:  [<c03042c9>] tcp_close+0x22b/0x556
Jan 28 22:58:29 euridica kernel:  [<c031d595>] inet_release+0x43/0x49
Jan 28 22:58:29 euridica kernel:  [<c02d74c8>] sock_release+0x17/0x9d
Jan 28 22:58:29 euridica kernel:  [<c02d7843>] sock_close+0x2d/0x33
Jan 28 22:58:29 euridica kernel:  [<c0178a0a>] __fput+0xca/0x198
Jan 28 22:58:29 euridica kernel:  [<c0178c44>] fput+0x32/0x36
Jan 28 22:58:29 euridica kernel:  [<c017606a>] filp_close+0x54/0x5c
Jan 28 22:58:29 euridica kernel:  [<c0124e72>] put_files_struct+0x7d/0x=
ba
Jan 28 22:58:29 euridica kernel:  [<c012625e>] do_exit+0x30d/0x8e6
Jan 28 22:58:29 euridica kernel:  [<c01268b9>] sys_exit_group+0x0/0x11
Jan 28 22:58:29 euridica kernel:  [<c012f177>] get_signal_to_deliver+0x=
734/0x760
Jan 28 22:58:29 euridica kernel:  [<c010391e>] do_notify_resume+0x94/0x=
749
Jan 28 22:58:29 euridica kernel:  [<c01044a1>] work_notifysig+0x13/0x1a
Jan 28 22:58:29 euridica kernel:  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

http://www.stardust.webpages.pl/files/tbf/euridica/2.6.20-rc6-mm1/mm-co=
nfig

Regards,
Michal

--=20
Michal K. K. Piotrowski
LTG - Linux Testers Group
(http://www.stardust.webpages.pl/ltg/)
