From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 6/8] bnx2x: Add known PHY type check
Date: Sun, 27 Nov 2011 17:01:00 -0500 (EST)
Message-ID: <20111127.170100.379387551488831733.davem@davemloft.net>
References: <1322417881-17760-1-git-send-email-yanivr@broadcom.com>
	<1322417881-17760-7-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: yanivr@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47244 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753122Ab1K0WBE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2011 17:01:04 -0500
In-Reply-To: <1322417881-17760-7-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yaniv Rosner" <yanivr@broadcom.com>
Date: Sun, 27 Nov 2011 20:17:59 +0200

> +		if ((phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) &&
> +			(phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_NOT_CONN))
> +			return -EINVAL;

Please format this correctly:

		if ((phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) &&
		    (phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_NOT_CONN))
			return -EINVAL;

If you can't get the tabs right by hand, use something that does
it transparently for you such as C-mode in emacs.
