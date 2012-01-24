From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 1/5] net: Introduce new feature setting ops
Date: Tue, 24 Jan 2012 14:54:03 +0100
Message-ID: <1327413243.7231.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <cover.1296741561.git.mirq-linux@rere.qmqm.pl>
	 <9327efbf43fadeadd7017926962c65c95288d50e.1296741561.git.mirq-linux@rere.qmqm.pl>
	 <1297107597.4077.8.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:55284 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754924Ab2AXNyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2012 08:54:08 -0500
Received: by werb13 with SMTP id b13so2965587wer.19
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2012 05:54:06 -0800 (PST)
In-Reply-To: <1297107597.4077.8.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 07 f=C3=A9vrier 2011 =C3=A0 19:39 +0000, Ben Hutchings a =C3=A9=
crit :
> On Thu, 2011-02-03 at 15:21 +0100, Micha=C5=82 Miros=C5=82aw wrote:
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
> Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>
>=20


Hi guys

Do we have any ethtool patch to use these 'new' features ?

Thanks
