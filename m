From: Lance Lassetter <lancelassetter@gmail.com>
Subject: Re: r8169 with 3.9.0-rc9
Date: Fri, 26 Apr 2013 23:12:33 -0500
Message-ID: <20130427041230.GA18709@gmail.com>
References: <20130426132254.GA22821@gmail.com>
 <20130426205018.GA18092@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f174.google.com ([209.85.213.174]:56545 "EHLO
	mail-ye0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751186Ab3D0EMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Apr 2013 00:12:38 -0400
Received: by mail-ye0-f174.google.com with SMTP id l14so330014yen.19
        for <netdev@vger.kernel.org>; Fri, 26 Apr 2013 21:12:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130426205018.GA18092@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 26, 2013 at 10:50:18PM +0200, Francois Romieu wrote:
> Lance Lassetter <lancelassetter@gmail.com> :
> [...]
> > the box serves as a network router so it is causing abundant networ=
k
> > traffic problems.
> >=20
> > any debugging i could help you with, please let me know.=A0 also if=
 there
> > is a possible solution, please let me know.
>=20
> Is it a regression and / or an Asus M5A97 system ?
>=20
> The XID lines that the kernel printed when the r8169 module gets load=
ed
> may help.
>=20
> --=20
> Ueimor

lance@annun10 ~$ dmesg | grep -i xid
[    6.370821] r8169 0000:03:00.0 eth0: RTL8168c/8111c at 0xffffc90000c=
70000, 00
:22:19:28:86:61, XID 1c4000c0 IRQ 45
[    6.371103] r8169 0000:04:09.0 eth1: RTL8169sb/8110sb at 0xffffc9000=
0c7ec00,
48:02:2a:07:90:45, XID 10000000 IRQ 20
lance@annun10 ~$

i don't think it's a regression and it's a Dell XPS 625 with an addon r=
8169 so there are two r8169 cards in the system.  it is a testing fedor=
a repository system though with vanilla mainline kernel.

hope this helps,

lance
