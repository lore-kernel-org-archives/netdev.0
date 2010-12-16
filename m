From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH 04/12] net: introduce NETIF_F_RXCSUM
Date: Thu, 16 Dec 2010 23:27:29 +0000
Message-ID: <1292542049.18294.25.camel@bwh-desktop>
References: <cover.1292451559.git.mirq-linux@rere.qmqm.pl>
	 <fcee74e8b71430c0e0c267ac180f5861c471dc41.1292451560.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:37296 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751379Ab0LPX1c convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 18:27:32 -0500
In-Reply-To: <fcee74e8b71430c0e0c267ac180f5861c471dc41.1292451560.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-12-15 at 23:24 +0100, Micha=C5=82 Miros=C5=82aw wrote:
> Introduce NETIF_F_RXCSUM to replace device-private flags for RX check=
sum
> offload. Integrate it with ndo_fix_features.
>=20
> ethtool_op_get_rx_csum() is removed altogether as nothing in-tree use=
s it.

Not explicitly, but what about drivers that turn TX and RX checksumming
on and off together?  They are implicitly covered by the case which
you're removing:

[...]
> -	case ETHTOOL_GRXCSUM:
> -		rc =3D ethtool_get_value(dev, useraddr, ethcmd,
> -				       (dev->ethtool_ops->get_rx_csum ?
> -					dev->ethtool_ops->get_rx_csum :
> -					ethtool_op_get_rx_csum));
[...]

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

