From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] smsc95xx: support PHY wakeup source
Date: Wed, 21 Nov 2012 12:07:21 -0500 (EST)
Message-ID: <20121121.120721.1391625922017753607.davem@davemloft.net>
References: <1353504577-5719-1-git-send-email-steve.glendinning@shawell.net>
	<1353504577-5719-2-git-send-email-steve.glendinning@shawell.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steve.glendinning@shawell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53522 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750958Ab2KURHW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 12:07:22 -0500
In-Reply-To: <1353504577-5719-2-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@shawell.net>
Date: Wed, 21 Nov 2012 13:29:37 +0000

> +{
> +	struct mii_if_info *mii = &dev->mii;
> +
> +        /* first, a dummy read, needed to latch some MII phys */
> +	int ret = smsc95xx_mdio_read_nopm(dev->net, mii->phy_id, MII_BMSR);

Please keep the local variable declarations together at the beginning
of the basic block, don't intermix empty lines and comments as you
are doing here.
