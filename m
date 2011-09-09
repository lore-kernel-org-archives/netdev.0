From: David Madore <david+ml@madore.org>
Subject: Re: possible routing table cache bug for mtu/advmss attributes in
 Linux 3.0.4
Date: Fri, 9 Sep 2011 23:28:15 +0200
Message-ID: <20110909212815.GA5651@aldebaran.gro-tsen.net>
References: <20110901214643.GA16989@aldebaran.gro-tsen.net>
 <CAAM7YA=t=s5EEVFte84oqWaKfqyoNhX_NsE5xWUKJ53u-+Es=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev Mailing-List <netdev@vger.kernel.org>
To: "Yan, Zheng " <yanzheng@21cn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aldebaran.gro-tsen.net ([88.191.60.176]:54482 "EHLO
	aldebaran.gro-tsen.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933345Ab1IIV2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2011 17:28:17 -0400
Content-Disposition: inline
In-Reply-To: <CAAM7YA=t=s5EEVFte84oqWaKfqyoNhX_NsE5xWUKJ53u-+Es=g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 08, 2011 at 10:42:20PM +0800, Yan, Zheng  wrote:
> On Fri, Sep 2, 2011 at 5:46 AM, David Madore <david+ml@madore.org> wr=
ote:
> > In a nutshell, the problem is this: my (manually entered) routing
> > tables specify an explicit MTU/MSS for certain IPv6 routes, and aft=
er
> > upgrading from 2.6.38.7 to 3.0.4, I found that this MTU/MSS setting=
 is
> > sometimes ignored. =A0More precisely, it seems that connecting to a=
 host
> > through the route in question causes a routing cache entry to be
> > created, and it is when this cache entry expires that the route
> > forgets the MTU/MSS setting. =A0(It may also be relevant that in my=
 case
> > the route belongs to a routing table other than "main".)
>=20
> Would you please try patch http://marc.info/?l=3Dlinux-netdev&m=3D131=
529445904858

Indeed, this appears to solve the problem I encountered.  Thanks!

--=20
     David A. Madore
   ( http://www.madore.org/~david/ )
