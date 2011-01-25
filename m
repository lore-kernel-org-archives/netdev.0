From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2 04/16] net: Introduce new feature setting ops
Date: Tue, 25 Jan 2011 11:26:01 +1000
Message-ID: <1295918761.4105.7.camel@localhost>
References: <cover.1295734270.git.mirq-linux@rere.qmqm.pl>
	 <7f0bf8e3fa40db0e188fc6310a5dd670718c0fc0.1295734271.git.mirq-linux@rere.qmqm.pl>
	 <20110124.155144.35028895.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mirq-linux@rere.qmqm.pl, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:31473 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752608Ab1AYB0D convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jan 2011 20:26:03 -0500
In-Reply-To: <20110124.155144.35028895.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-01-24 at 15:51 -0800, David Miller wrote:
> From: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> Date: Sat, 22 Jan 2011 23:14:13 +0100 (CET)
>=20
> > This introduces a new framework to handle device features setting.
> > It consists of:
> >   - new fields in struct net_device:
> > 	+ hw_features - features that hw/driver supports toggling
> > 	+ wanted_features - features that user wants enabled, when possibl=
e
> >   - new netdev_ops:
> > 	+ feat =3D ndo_fix_features(dev, feat) - API checking constraints =
for
> > 		enabling features or their combinations
> > 	+ ndo_set_features(dev) - API updating hardware state to match
> > 		changed dev->features
> >   - new ethtool commands:
> > 	+ ETHTOOL_GFEATURES/ETHTOOL_SFEATURES: get/set dev->wanted_feature=
s
> > 		and trigger device reconfiguration if resulting dev->features
> > 		changed
> > 	+ ETHTOOL_GSTRINGS(ETH_SS_FEATURES): get feature bits names (meani=
ng)
> >=20
> > Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
>=20
> Ok, I'll stop applying patches right before this one as I'd like to s=
ee
> at least some feedback from Ben wrt. the ethtool bits.
>=20
> FWIW I like these changes (a lot). :-)

These are on my list to review.  I'm at LCA now (and not on work time)
but I'll try to get through them in the next day or two.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

