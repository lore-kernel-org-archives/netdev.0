From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] sfc: Allow driver to cope with a lower
 number of VIs than it needs for RSS
Date: Fri, 28 Aug 2015 13:54:07 -0700 (PDT)
Message-ID: <20150828.135407.681828001083476161.davem@davemloft.net>
References: <55E0301E.30009@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: sshah@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55793 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752813AbbH1UyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 16:54:08 -0400
In-Reply-To: <55E0301E.30009@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shradha Shah <sshah@solarflare.com>
Date: Fri, 28 Aug 2015 10:55:42 +0100

> Previously, the driver would refuse to load if it couldn't secure
> enough VIs from the MC to fulfill its RSS requirements.
> This was causing probe to fail on later functions in
> configurations where we'd run out of VIs, such as having many
> VFs.
> 
> This change allows the driver to load with fewer VIs, down to a
> minimum of 2. A warning will be printed saying that RSS
> requirements were not met, possibly affecting performance.
> 
> efx->max_tx_channels needs to be set to avoid going down the
> failure path in efx_probe_nic() immediately in the loop after the
> probe() NIC-type function.
> Also, Set rc=ENOSPC when bombing out of efx_probe_nic due to lack
> of VIs.
> 
> Signed-off-by: Shradha Shah <sshah@solarflare.com>

Applied, thanks.
