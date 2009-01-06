From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dm9601: handle corrupt mac address
Date: Tue, 06 Jan 2009 10:55:41 -0800 (PST)
Message-ID: <20090106.105541.165809083.davem@davemloft.net>
References: <20090106061414.GA3677@localhost>
	<87hc4cvp05.fsf@macbook.be.48ers.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wfg@linux.intel.com, netdev@vger.kernel.org
To: jacmet@sunsite.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49791
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751684AbZAFSzj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 13:55:39 -0500
In-Reply-To: <87hc4cvp05.fsf@macbook.be.48ers.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Korsgaard <jacmet@sunsite.dk>
Date: Tue, 06 Jan 2009 09:04:58 +0100

> >>>>> "Wu" == Wu Fengguang <wfg@linux.intel.com> writes:
> 
>  Wu> Some cheap devices ship with dangling EEPROM pins!
>  Wu> They always return invalid address ff:ff:ff:ff:ff:ff.
> 
>  Wu> Inherit the auto-generated address in this case,
>  Wu> so that these products can work with zero configuration.
> 
>  Wu> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> 
>  Wu> +	/*
>  Wu> +	 * Overwrite the auto-generated address only with good ones.
>  Wu> +	 */
>  Wu> +	if (is_valid_ether_addr(mac))
>  Wu> +		memcpy(dev->net->dev_addr, mac, ETH_ALEN);
>  Wu> +
> 
> Do we automatically get a random address in netdev nowadays without
> calling random_ether_addr? I didn't know that.
> 
> Anyway, I would prefer to add a dev_warn mentioning the fact that
> we're using a random address (and which one).
> 
> Other than that,
> 
> Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>

Applied, thanks everyone.
