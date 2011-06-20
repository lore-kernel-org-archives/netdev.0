From: David Miller <davem@davemloft.net>
Subject: Re: [RFT PATCH 3/9] net: ethtool: break association of ETH_FLAG_*
 with NETIF_F_*
Date: Mon, 20 Jun 2011 13:27:25 -0700 (PDT)
Message-ID: <20110620.132725.213071337260033672.davem@davemloft.net>
References: <cover.1308596962.git.mirq-linux@rere.qmqm.pl>
	<51d2fd4cf6855c2285ca9bcd8d267abedcbc599c.1308596963.git.mirq-linux@rere.qmqm.pl>
	<1308600681.2701.159.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mirq-linux@rere.qmqm.pl, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59382 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752128Ab1FTU1h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 16:27:37 -0400
In-Reply-To: <1308600681.2701.159.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 20 Jun 2011 21:11:21 +0100

> If we're going to keep changing features (maybe even more often) then we
> have to do something about this sysfs attribute.  Maybe get rid of it
> (as it seems not to be widely used, thankfully).  Maybe fix it to use
> the same feature values as today, but no new features.  But certainly
> don't pretend that feature flags are not exposed.

I'd say we just kill it off, our hands are tied too tightly otherwise.

And this ties in to our efforts to expand netdev->features to a larger
type.
