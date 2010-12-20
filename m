From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Kernel panic eth2 mirred redirect to ifb0
Date: Mon, 20 Dec 2010 13:02:47 +0000
Message-ID: <20101220130247.GB9325@ff.dom.local>
References: <AANLkTi=R_ZsYgsYd7EkxHRFTKjtLyLQAOYay2nBV=0bK@mail.gmail.com> <1292836885.2800.4.camel@edumazet-laptop> <20101220103226.GB7977@ff.dom.local> <1292841671.2800.11.camel@edumazet-laptop> <20101220111141.GC7977@ff.dom.local> <20101220115855.GD7977@ff.dom.local> <4D0F471D.8030607@itcare.pl> <20101220122256.GA9325@ff.dom.local> <1292849150.2800.25.camel@edumazet-laptop> <1292849687.2800.27.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>,
	Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:42196 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751750Ab0LTNCu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 08:02:50 -0500
Received: by fxm18 with SMTP id 18so2988163fxm.2
        for <netdev@vger.kernel.org>; Mon, 20 Dec 2010 05:02:49 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1292849687.2800.27.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 20, 2010 at 01:54:47PM +0100, Eric Dumazet wrote:
> Le lundi 20 d=E9cembre 2010 ?? 13:45 +0100, Eric Dumazet a =E9crit :
> > Le lundi 20 d=E9cembre 2010 ?? 12:22 +0000, Jarek Poplawski a =E9cr=
it :
> > > On Mon, Dec 20, 2010 at 01:07:57PM +0100, Pawe=B3 Staszewski wrot=
e:
> > > > I have the same panic as without.
> > > >
> > > > This patch was added to clean 2.6.37-rc6 - without previous pat=
ch for =20
> > > > sch_generic.h
> > > >
> > > > Attached image with kernel panic.
> > >=20
> > > This one is definitely the nicest ;-)
> >=20
> > Indeed, we finally can see where it happens ;)
> >=20
>=20
> Shouldnt ifb adds some dev->features, like NETIF_F_FRAGLIST /
> NETIF_F_SG ?
>=20

IMHO it should, (probably even more, like loopback) but we should
consider mirred can xmit to other than ifb too.

Jarek P.
