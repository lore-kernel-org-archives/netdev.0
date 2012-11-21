From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] smsc95xx: detect chip revision specific features
Date: Wed, 21 Nov 2012 12:06:24 -0500 (EST)
Message-ID: <20121121.120624.1065160311329180185.davem@davemloft.net>
References: <1353504577-5719-1-git-send-email-steve.glendinning@shawell.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steve.glendinning@shawell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53513 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750958Ab2KURG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 12:06:26 -0500
In-Reply-To: <1353504577-5719-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@shawell.net>
Date: Wed, 21 Nov 2012 13:29:36 +0000

> +	if ((val == ID_REV_CHIP_ID_9500A_) || (val == ID_REV_CHIP_ID_9530_) ||
> +		(val == ID_REV_CHIP_ID_89530_) || (val == ID_REV_CHIP_ID_9730_))
> +		pdata->features = FEATURE_8_WAKEUP_FILTERS
> +			| FEATURE_PHY_NLP_CROSSOVER | FEATURE_AUTOSUSPEND;

Please style this properly.

	if ((val == ID_REV_CHIP_ID_9500A_) || (val == ID_REV_CHIP_ID_9530_) ||
	    (val == ID_REV_CHIP_ID_89530_) || (val == ID_REV_CHIP_ID_9730_))
		pdata->features = (FEATURE_8_WAKEUP_FILTERS |
				   FEATURE_PHY_NLP_CROSSOVER |
				   FEATURE_AUTOSUSPEND);
