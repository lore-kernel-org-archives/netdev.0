From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 1/5] net: Introduce new feature setting ops
Date: Mon, 07 Feb 2011 12:51:20 -0800 (PST)
Message-ID: <20110207.125120.71110722.davem@davemloft.net>
References: <cover.1296741561.git.mirq-linux@rere.qmqm.pl>
	<9327efbf43fadeadd7017926962c65c95288d50e.1296741561.git.mirq-linux@rere.qmqm.pl>
	<1297107597.4077.8.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mirq-linux@rere.qmqm.pl, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43698
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751334Ab1BGUup (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Feb 2011 15:50:45 -0500
In-Reply-To: <1297107597.4077.8.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 07 Feb 2011 19:39:57 +0000

> On Thu, 2011-02-03 at 15:21 +0100, Micha=A9=A9 Miros=A9=A9aw wrote:
>> This introduces a new framework to handle device features setting.
>> It consists of:
>>   - new fields in struct net_device:
>> 	+ hw_features - features that hw/driver supports toggling
>> 	+ wanted_features - features that user wants enabled, when possible
>>   - new netdev_ops:
>> 	+ feat =3D ndo_fix_features(dev, feat) - API checking constraints f=
or
>> 		enabling features or their combinations
>> 	+ ndo_set_features(dev) - API updating hardware state to match
>> 		changed dev->features
>>   - new ethtool commands:
>> 	+ ETHTOOL_GFEATURES/ETHTOOL_SFEATURES: get/set dev->wanted_features
>> 		and trigger device reconfiguration if resulting dev->features
>> 		changed
>> 	+ ETHTOOL_GSTRINGS(ETH_SS_FEATURES): get feature bits names (meanin=
g)
>>=20
>> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
> Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

Applied, thanks.
