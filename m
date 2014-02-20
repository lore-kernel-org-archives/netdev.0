From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 3/3] ixgbe: Check config reads for removal
Date: Thu, 20 Feb 2014 13:32:21 -0500 (EST)
Message-ID: <20140220.133221.371192280746136183.davem@davemloft.net>
References: <1392871521-7731-1-git-send-email-aaron.f.brown@intel.com>
	<1392871521-7731-4-git-send-email-aaron.f.brown@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mark.d.rustad@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: aaron.f.brown@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57879 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754371AbaBTScX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Feb 2014 13:32:23 -0500
In-Reply-To: <1392871521-7731-4-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Brown <aaron.f.brown@intel.com>
Date: Wed, 19 Feb 2014 20:45:21 -0800

> -	if (!(IXGBE_READ_REG(hw, IXGBE_STATUS) & IXGBE_STATUS_GIO))
> +	if (!(IXGBE_READ_REG(hw, IXGBE_STATUS) & IXGBE_STATUS_GIO) ||
> +		ixgbe_removed(hw->hw_addr))
>  		goto out;

This is not indented correctly, the second line of the if() statement
should start at the first column after the openning parenthesis of the
top-level if() statement.

> +	if (*value == IXGBE_FAILED_READ_CFG_WORD &&
> +	    ixgbe_check_cfg_remove(&adapter->hw, parent_dev))
> +		return -1;

Just as you correctly did here.
