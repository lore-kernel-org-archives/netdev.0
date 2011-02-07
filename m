From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v4 1/5] net: Introduce new feature setting ops
Date: Mon, 07 Feb 2011 19:39:57 +0000
Message-ID: <1297107597.4077.8.camel@bwh-desktop>
References: <cover.1296741561.git.mirq-linux@rere.qmqm.pl>
	 <9327efbf43fadeadd7017926962c65c95288d50e.1296741561.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:20321 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754526Ab1BGTj7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Feb 2011 14:39:59 -0500
In-Reply-To: <9327efbf43fadeadd7017926962c65c95288d50e.1296741561.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-02-03 at 15:21 +0100, Micha=C5=82 Miros=C5=82aw wrote:
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
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

