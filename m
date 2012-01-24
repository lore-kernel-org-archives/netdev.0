From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH v4 1/5] net: Introduce new feature setting ops
Date: Tue, 24 Jan 2012 20:05:13 +0100
Message-ID: <20120124190513.GC19993@rere.qmqm.pl>
References: <cover.1296741561.git.mirq-linux@rere.qmqm.pl>
 <9327efbf43fadeadd7017926962c65c95288d50e.1296741561.git.mirq-linux@rere.qmqm.pl>
 <1297107597.4077.8.camel@bwh-desktop>
 <1327413243.7231.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1327419002.5400.27.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:53554 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750883Ab2AXTFP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jan 2012 14:05:15 -0500
Content-Disposition: inline
In-Reply-To: <1327419002.5400.27.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 24, 2012 at 03:30:02PM +0000, Ben Hutchings wrote:
> On Tue, 2012-01-24 at 14:54 +0100, Eric Dumazet wrote:
> > Le lundi 07 f=C3=A9vrier 2011 =C3=A0 19:39 +0000, Ben Hutchings a =C3=
=A9crit :
> > > On Thu, 2011-02-03 at 15:21 +0100, Micha=C5=82 Miros=C5=82aw wrot=
e:
> > > > This introduces a new framework to handle device features setti=
ng.
> > > > It consists of:
> > > >   - new fields in struct net_device:
> > > > 	+ hw_features - features that hw/driver supports toggling
> > > > 	+ wanted_features - features that user wants enabled, when pos=
sible
> > > >   - new netdev_ops:
> > > > 	+ feat =3D ndo_fix_features(dev, feat) - API checking constrai=
nts for
> > > > 		enabling features or their combinations
> > > > 	+ ndo_set_features(dev) - API updating hardware state to match
> > > > 		changed dev->features
> > > >   - new ethtool commands:
> > > > 	+ ETHTOOL_GFEATURES/ETHTOOL_SFEATURES: get/set dev->wanted_fea=
tures
> > > > 		and trigger device reconfiguration if resulting dev->features
> > > > 		changed
> > > > 	+ ETHTOOL_GSTRINGS(ETH_SS_FEATURES): get feature bits names (m=
eaning)
> > > >=20
> > > > Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.=
pl>
> > > Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>
> > Do we have any ethtool patch to use these 'new' features ?
> I have some unfinished changes to support this.  What I don't want to=
 do
> is to add an entirely separate set of options; I want -k/-K to work w=
ith
> old and new kernel versions, supporting named features as an extensio=
n
> where available.

Ben, what are your patches like?  I mean their state?  I'm asking, beca=
use I
found a bit of time and rebased my earlier patch to current ethtool 3.2
this weekend.  Haven't sent them yet, because I'm seeing -EOPNOTSUPP fr=
om
kernel on x86_64 for GFEATURES and I'm trying to figure out where's the=
 bug.

Best Regards,
Micha=C5=82 Miros=C5=82aw
