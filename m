From: David Miller <davem@davemloft.net>
Subject: Re: WARNING: at net/ipv4/tcp_input.c:2173
 tcp_mark_head_lost+0x173/0x1a0()
Date: Fri, 11 Apr 2008 11:22:33 -0700 (PDT)
Message-ID: <20080411.112233.262377127.davem@davemloft.net>
References: <20080403211913.3a0c1d00.akpm@linux-foundation.org>
	<200804041150.34046.rjw@sisk.pl>
	<Pine.LNX.4.64.0804111553450.28474@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: robbat2@gentoo.org, rjw@sisk.pl, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	gf@unixsol.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36692
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759846AbYDKSWc convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2008 14:22:32 -0400
In-Reply-To: <Pine.LNX.4.64.0804111553450.28474@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Fri, 11 Apr 2008 16:05:32 +0300 (EEST)

> On Fri, 4 Apr 2008, Rafael J. Wysocki wrote:
>=20
> > That's http://bugzilla.kernel.org/show_bug.cgi?id=3D10346 , I think=
=2E=20
> >=20
> > Robin, please add yourself to the CC list in the bugzilla entry abo=
ve.
> >=20
> > > > One of the nodes in my web-serving cluster (isohunt.com) starte=
d showing this:
> > > >=20
> > > > ------------[ cut here ]------------
> > > > WARNING: at net/ipv4/tcp_input.c:2173 tcp_mark_head_lost+0x173/=
0x1a0()
>=20
> Once Linus pulls net-2.6 fixes in, Robin's bug should be among the fi=
xed=20
> ones (NewReno&TSO fix). ...Whereas the bugzilla's report might be due=
 to=20
> another bug (it's different warn_on in any case).

Linus has pulled those changes in.
