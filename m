From: =?iso-8859-1?Q?Llu=EDs?= Batlle i Rossell <viric@viric.name>
Subject: Re: unable to handle paging request, arm, at aio/tcp code, only 3.6
Date: Mon, 19 Nov 2012 22:10:20 +0100
Message-ID: <20121119211020.GL2068@vicerveza.homeunix.net>
References: <20121119183222.GI2068@vicerveza.homeunix.net>
 <1353354095.10798.76.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mho-04-ewr.mailhop.org ([204.13.248.74]:62485 "EHLO
	mho-02-ewr.mailhop.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751791Ab2KSVLt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 16:11:49 -0500
Content-Disposition: inline
In-Reply-To: <1353354095.10798.76.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 19, 2012 at 11:41:35AM -0800, Eric Dumazet wrote:
> On Mon, 2012-11-19 at 19:32 +0100, Llu=EDs Batlle i Rossell wrote:
> > (crosspost from lkml)
> > Hello,
> >=20
> > in a Sheevaplug (armv5tel), if I run the kernels 3.6.3 or 3.6.6, th=
ey crash in
> > less than 48h. Kernel 3.5.3 runs perfect, as most previous kernels =
I've been
> > running until 2.6.36.
> >=20
> > Can anyone suggest what change can be the cause of that?
> > Or how could I debug this to fix it?
> >=20
> > Here is the panic:
> > unable to handle kernel paging request at virtual address ffffffab
> > pgd =3D d864c000
> > [ffffffab] *pgd=3D1fffe831, *pte=3D00000000, *ppte=3D00000000
> > Internal error: Oops: 1 [#1] PREEMPT ARM
> > Modules linked in: netconsole cbc sg cryptodev(O) fuse ipv6 ums_cyp=
ress dm_mod btrfs ext4 jb
> > d2 reiserfs [last unloaded: netconsole]
> > CPU: 0    Tainted: G           O  (3.6.6 #1)
> > PC is at tcp_v6_mtu_reduced+0x40/0x80 [ipv6]
> > LR is at ip6_dst_lookup_tail+0xd8/0xfc [ipv6]
> > pc : [<bf2b02f8>]    lr : [<bf28a67c>]    psr: a0000013
> > ...
> Thanks for the report.
>=20
> I believe this is a regression of commit
> 35ad9b9cf7d8a2e6259a0d24022e910adb6f3489
> (ipv6: Add helper inet6_csk_update_pmtu().)
>=20
> I'll prepare a patch to fix this.

If it can help, I keep the vmlinux kernel with debug info.

Regards,
Llu=EDs.
