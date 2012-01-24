From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v4 1/5] net: Introduce new feature setting ops
Date: Tue, 24 Jan 2012 15:30:02 +0000
Message-ID: <1327419002.5400.27.camel@deadeye>
References: <cover.1296741561.git.mirq-linux@rere.qmqm.pl>
	 <9327efbf43fadeadd7017926962c65c95288d50e.1296741561.git.mirq-linux@rere.qmqm.pl>
	 <1297107597.4077.8.camel@bwh-desktop>
	 <1327413243.7231.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	<netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:41067 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750854Ab2AXPaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2012 10:30:08 -0500
In-Reply-To: <1327413243.7231.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-01-24 at 14:54 +0100, Eric Dumazet wrote:
> Le lundi 07 f=C3=A9vrier 2011 =C3=A0 19:39 +0000, Ben Hutchings a =C3=
=A9crit :
> > On Thu, 2011-02-03 at 15:21 +0100, Micha=C5=82 Miros=C5=82aw wrote:
> > > This introduces a new framework to handle device features setting=
=2E
> > > It consists of:
> > >   - new fields in struct net_device:
> > > 	+ hw_features - features that hw/driver supports toggling
> > > 	+ wanted_features - features that user wants enabled, when possi=
ble
> > >   - new netdev_ops:
> > > 	+ feat =3D ndo_fix_features(dev, feat) - API checking constraint=
s for
> > > 		enabling features or their combinations
> > > 	+ ndo_set_features(dev) - API updating hardware state to match
> > > 		changed dev->features
> > >   - new ethtool commands:
> > > 	+ ETHTOOL_GFEATURES/ETHTOOL_SFEATURES: get/set dev->wanted_featu=
res
> > > 		and trigger device reconfiguration if resulting dev->features
> > > 		changed
> > > 	+ ETHTOOL_GSTRINGS(ETH_SS_FEATURES): get feature bits names (mea=
ning)
> > >=20
> > > Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl=
>
> > Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>
> >=20
>=20
>=20
> Hi guys
>=20
> Do we have any ethtool patch to use these 'new' features ?

I have some unfinished changes to support this.  What I don't want to d=
o
is to add an entirely separate set of options; I want -k/-K to work wit=
h
old and new kernel versions, supporting named features as an extension
where available.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
