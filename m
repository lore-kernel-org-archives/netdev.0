From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: added support for 40GbE link.
Date: Tue, 19 Jun 2012 00:29:05 -0700 (PDT)
Message-ID: <20120619.002905.922583388766089167.davem@davemloft.net>
References: <0c7c97b0-bfe1-4143-a562-2019f86912fc@exht1.ad.emulex.com>
	<1340039376.2913.13.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: parav.pandit@emulex.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51348 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753239Ab2FSH3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 03:29:06 -0400
In-Reply-To: <1340039376.2913.13.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 18 Jun 2012 18:09:36 +0100

> On Mon, 2012-06-18 at 18:14 +0530, Parav Pandit wrote:
...
>> -/* The forced speed, 10Mb, 100Mb, gigabit, 2.5Gb, 10GbE. */
>> +/* The forced speed, 10Mb, 100Mb, gigabit, 2.5Gb, 10GbE, 40GbE. */
> 
> I don't think there's any need to name all possible link speeds, and it
> just encourages the bad practice of ethtool API users checking for
> specific values.  You may notice there is no SPEED_20000.

Agreed.

>> @@ -542,13 +542,11 @@ static int prb_calc_retire_blk_tmo(struct packet_sock *po,
 ...
> This function should be fixed properly.  Firstly, it must use
> ethtool_cmd_speed() rather than directly accessing ecmd.speed.
> Secondly, it should allow any speed value rather than checking for
> specific values.  Then there will be no need to make further changes for
> 100G or any other new speed.

Agreed.
