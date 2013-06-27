From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 2/3] pch_gbe: convert pr_* to netdev_*
Date: Thu, 27 Jun 2013 07:33:59 -0700
Message-ID: <1372343639.2060.6.camel@joe-AO722>
References: <1372324994-27793-1-git-send-email-andriy.shevchenko@linux.intel.com>
	 <1372324994-27793-3-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Darren Hart <dvhart@linux.intel.com>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:46400 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753725Ab3F0Od7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jun 2013 10:33:59 -0400
In-Reply-To: <1372324994-27793-3-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-06-27 at 12:23 +0300, Andy Shevchenko wrote:
> We may use nice macros to prefix our messages with proper device name.
[]
> diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
[]
> @@ -573,7 +581,7 @@ u16 pch_gbe_mac_ctrl_miim(struct pch_gbe_hw *hw, u32 addr, u32 dir, u32 reg,
>  	}
>  	spin_unlock_irqrestore(&hw->miim_lock, flags);
>  
> -	pr_debug("PHY %s: reg=%d, data=0x%04X\n",
> +	netdev_dbg(adapter->netdev, "PHY %s: reg=%d, data=0x%04X\n",
>  		 dir == PCH_GBE_MIIM_OPER_READ ? "READ" : "WRITE", reg,
>  		 dir == PCH_GBE_MIIM_OPER_READ ? data_out : data);

Hi Andy.

Please make sure to realign the additional
arguments on subsequent lines to the open
parenthesis.

(there are several of these)
