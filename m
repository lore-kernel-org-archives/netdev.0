From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] ether1: Use net_device_stats from struct net_device
Date: Wed, 18 Aug 2010 10:27:53 +0200
Message-ID: <1282120073.2194.40.camel@edumazet-laptop>
References: <1282061719-19645-1-git-send-email-tklauser@distanz.ch>
	 <1282115064-3701-1-git-send-email-tklauser@distanz.ch>
	 <20100818081306.GA9149@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tobias Klauser <tklauser@distanz.ch>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	kernel-janitors@vger.kernel.org, Dan Carpenter <error27@gmail.com>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:49683 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750882Ab0HRI16 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 04:27:58 -0400
In-Reply-To: <20100818081306.GA9149@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 18 ao=C3=BBt 2010 =C3=A0 09:13 +0100, Russell King - ARM Li=
nux a
=C3=A9crit :
> On Wed, Aug 18, 2010 at 09:04:24AM +0200, Tobias Klauser wrote:
> > @@ -965,7 +965,7 @@ ether1_close (struct net_device *dev)
> >  static struct net_device_stats *
> >  ether1_getstats (struct net_device *dev)
> >  {
> > -	return &priv(dev)->stats;
> > +	return &dev->stats;
> >  }
>=20
> Doesn't the core do this for you already if you omit this function?
>=20
> Same comment for ether3.c

Yes, thats right, no need to declare ndo_get_stats() methods that only
returns &dev->stats



