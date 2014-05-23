From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-next:v4: Add support to configure SR-IOV VF
 minimum and maximum Tx rate through ip tool.
Date: Fri, 23 May 2014 15:04:30 -0400 (EDT)
Message-ID: <20140523.150430.1641352816152114168.davem@davemloft.net>
References: <1400767145-11564-1-git-send-email-sucheta.chakraborty@qlogic.com>
	<1400767145-11564-2-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept-HSGLinuxNICDev@qlogic.com,
	ben@decadent.org.uk, gregory.v.rose@intel.com,
	linux-net-drivers@solarflare.com, Ariel.Elior@qlogic.com,
	amirv@mellanox.com, mkubecek@suse.cz, stephen@networkplumber.org
To: sucheta.chakraborty@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54702 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751079AbaEWTEd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 15:04:33 -0400
In-Reply-To: <1400767145-11564-2-git-send-email-sucheta.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Date: Thu, 22 May 2014 09:59:05 -0400

> o min_tx_rate puts lower limit on the VF bandwidth. VF is guaranteed
>   to have a bandwidth of at least this value.
>   max_tx_rate puts cap on the VF bandwidth. VF can have a bandwidth
>   of up to this value.
> 
> o A new handler set_vf_rate for attr IFLA_VF_RATE has been introduced
>   which takes 4 arguments:
>   netdev, VF number, min_tx_rate, max_tx_rate
> 
> o ndo_set_vf_rate replaces ndo_set_vf_tx_rate handler.
> 
> o Drivers that currently implement ndo_set_vf_tx_rate should now call
>   ndo_set_vf_rate instead and reject attempt to set a minimum bandwidth
>   greater than 0 for IFLA_VF_TX_RATE when IFLA_VF_RATE is not yet
>   implemented by driver.
> 
> o If user enters only one of either min_tx_rate or max_tx_rate, then,
>   userland should read back the other value from driver and set both
>   for IFLA_VF_RATE.
>   Drivers that have not yet implemented IFLA_VF_RATE should always
>   return min_tx_rate as 0 when read from ip tool.
> 
> o If both IFLA_VF_TX_RATE and IFLA_VF_RATE options are specified, then
>   IFLA_VF_RATE should override.
> 
> o Idea is to have consistent display of rate values to user.
> 
> o Usage example: -
 ...
> Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

Looks good, applied to net-next, thanks.
