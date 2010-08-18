From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH v2] ether1: Use net_device_stats from struct net_device
Date: Wed, 18 Aug 2010 10:33:35 +0200
Message-ID: <20100818083335.GH15670@distanz.ch>
References: <1282061719-19645-1-git-send-email-tklauser@distanz.ch> <1282115064-3701-1-git-send-email-tklauser@distanz.ch> <20100818081306.GA9149@n2100.arm.linux.org.uk> <1282120073.2194.40.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	kernel-janitors@vger.kernel.org, Dan Carpenter <error27@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from symlink.to.noone.org ([85.10.207.172]:50449 "EHLO sym.noone.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750757Ab0HRIdh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 04:33:37 -0400
Content-Disposition: inline
In-Reply-To: <1282120073.2194.40.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-08-18 at 10:27:53 +0200, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mercredi 18 ao=FBt 2010 =E0 09:13 +0100, Russell King - ARM Linux =
a
> =E9crit :
> > On Wed, Aug 18, 2010 at 09:04:24AM +0200, Tobias Klauser wrote:
> > > @@ -965,7 +965,7 @@ ether1_close (struct net_device *dev)
> > >  static struct net_device_stats *
> > >  ether1_getstats (struct net_device *dev)
> > >  {
> > > -	return &priv(dev)->stats;
> > > +	return &dev->stats;
> > >  }
> >=20
> > Doesn't the core do this for you already if you omit this function?
> >=20
> > Same comment for ether3.c
>=20
> Yes, thats right, no need to declare ndo_get_stats() methods that onl=
y
> returns &dev->stats

Thanks. I'll send another updated patch, omitting the ether1_getstats
(same for ether3). Sorry for the mess.
