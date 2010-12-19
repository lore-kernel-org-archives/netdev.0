From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [RFC PATCH 04/12] net: introduce NETIF_F_RXCSUM
Date: Sun, 19 Dec 2010 01:57:15 +0100
Message-ID: <20101219005715.GC12005@rere.qmqm.pl>
References: <cover.1292451559.git.mirq-linux@rere.qmqm.pl> <fcee74e8b71430c0e0c267ac180f5861c471dc41.1292451560.git.mirq-linux@rere.qmqm.pl> <1292542049.18294.25.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:47646 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757179Ab0LSA5Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Dec 2010 19:57:16 -0500
Content-Disposition: inline
In-Reply-To: <1292542049.18294.25.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 16, 2010 at 11:27:29PM +0000, Ben Hutchings wrote:
> On Wed, 2010-12-15 at 23:24 +0100, Micha=B3 Miros=B3aw wrote:
> > Introduce NETIF_F_RXCSUM to replace device-private flags for RX che=
cksum
> > offload. Integrate it with ndo_fix_features.
> >=20
> > ethtool_op_get_rx_csum() is removed altogether as nothing in-tree u=
ses it.
> Not explicitly, but what about drivers that turn TX and RX checksummi=
ng
> on and off together?  They are implicitly covered by the case which
> you're removing:
> [...]
> > -	case ETHTOOL_GRXCSUM:
> > -		rc =3D ethtool_get_value(dev, useraddr, ethcmd,
> > -				       (dev->ethtool_ops->get_rx_csum ?
> > -					dev->ethtool_ops->get_rx_csum :
> > -					ethtool_op_get_rx_csum));
> [...]

I had an impression that drivers not defining get_rx_csum() had no
RX checksumming or didn't allow it to be toggled. I'll have a closer lo=
ok
on this.

Best Regards,
Micha=B3 Miros=B3aw
