From: Karsten Keil <kkeil@suse.de>
Subject: Re: [PATCH] [IPv6] Do not use loopback as source address on other interfaces
Date: Wed, 18 Jun 2008 16:25:47 +0200
Message-ID: <20080618142547.GC25004@pingi.kke.suse.de>
References: <20080618132312.GA25004@pingi.kke.suse.de> <20080618.223600.81071656.yoshfuji@linux-ipv6.org> <20080618140558.GB25004@pingi.kke.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>, kkeil@suse.de, netdev@vger.kernel.org,
	Mironov_Sergey@emc.com, akpm@linux-foundation.org,
	torvalds@linux-f
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:45722 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751803AbYFROZu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2008 10:25:50 -0400
Content-Disposition: inline
In-Reply-To: <20080618140558.GB25004@pingi.kke.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 18, 2008 at 04:05:58PM +0200, Karsten Keil wrote:
> On Wed, Jun 18, 2008 at 10:36:00PM +0900, YOSHIFUJI Hideaki / =E5=90=89=
=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> > In article <20080618132312.GA25004@pingi.kke.suse.de> (at Wed, 18 J=
un 2008 15:23:12 +0200), Karsten Keil <kkeil@suse.de> says:
> >=20
> > > RFC 4291 forbit the use of the loopback address as source outside=
 a node
> > > (paragraph 2.5.3).
> > >=20
> > > The latest TAHI test release 4.0.1 does have a check for this (IC=
MPv6 test
> > > v6LC.5.1.2 Part F), so it fails currently on Linux.
> > >=20
> > > Signed-off-by: Sergey Mironov <Mironov_Sergey@emc.com>
> > > Signed-off-by: Karsten Keil <kkeil@suse.de>
> >=20
> > I disagree this approach - too ad-hoc fix just to pass the tests.
> >=20
>=20
> So you would prefer a more general test in some common place (like
> __ip6_local_out() ) to avoid any packets with ::1 on other devices as
> loopback ?
>=20

I think that dropping pakets with destination ::1 in ipv6_rcv() for dev=
ices
!=3D loopback would be better reflect what RFC 4291 2.5.3 says.

--=20
Karsten Keil
SuSE Labs
ISDN and VOIP development
SUSE LINUX Products GmbH, Maxfeldstr.5 90409 Nuernberg, GF: Markus Rex,=
 HRB 16746 (AG Nuernberg)
