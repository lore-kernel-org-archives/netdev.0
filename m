From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 04/16] net: Introduce new feature setting ops
Date: Mon, 24 Jan 2011 15:51:44 -0800 (PST)
Message-ID: <20110124.155144.35028895.davem@davemloft.net>
References: <cover.1295734270.git.mirq-linux@rere.qmqm.pl>
	<7f0bf8e3fa40db0e188fc6310a5dd670718c0fc0.1295734271.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51937
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751522Ab1AXXvJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jan 2011 18:51:09 -0500
In-Reply-To: <7f0bf8e3fa40db0e188fc6310a5dd670718c0fc0.1295734271.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Sat, 22 Jan 2011 23:14:13 +0100 (CET)

> This introduces a new framework to handle device features setting.
> It consists of:
>   - new fields in struct net_device:
> 	+ hw_features - features that hw/driver supports toggling
> 	+ wanted_features - features that user wants enabled, when possible
>   - new netdev_ops:
> 	+ feat =3D ndo_fix_features(dev, feat) - API checking constraints fo=
r
> 		enabling features or their combinations
> 	+ ndo_set_features(dev) - API updating hardware state to match
> 		changed dev->features
>   - new ethtool commands:
> 	+ ETHTOOL_GFEATURES/ETHTOOL_SFEATURES: get/set dev->wanted_features
> 		and trigger device reconfiguration if resulting dev->features
> 		changed
> 	+ ETHTOOL_GSTRINGS(ETH_SS_FEATURES): get feature bits names (meaning=
)
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Ok, I'll stop applying patches right before this one as I'd like to see
at least some feedback from Ben wrt. the ethtool bits.

=46WIW I like these changes (a lot). :-)

