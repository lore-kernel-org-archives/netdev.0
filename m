From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] sfc: make TSO version a per-queue parameter
Date: Sun, 29 Nov 2015 22:50:41 -0500 (EST)
Message-ID: <20151129.225041.428082239866177063.davem@davemloft.net>
References: <5655DC18.7090208@solarflare.com>
	<5655DC76.7060607@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bkenward@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48223 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751840AbbK3Duo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2015 22:50:44 -0500
In-Reply-To: <5655DC76.7060607@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bert Kenward <bkenward@solarflare.com>
Date: Wed, 25 Nov 2015 16:06:14 +0000

>  	if (!(nic_data->datapath_caps &
> -	      (1 << MC_CMD_GET_CAPABILITIES_OUT_TX_TSO_LBN))) {
> -		netif_err(efx, drv, efx->net_dev,

Can you please keep code properly indented...

> +
> +	if (nic_data->datapath_caps &
> +			(1 << MC_CMD_GET_CAPABILITIES_OUT_TX_TSO_LBN)) {

when all you are doing is moving it from one place to another?

That first parenthesis on the second line must start exactly at the
first column after the openning parenthesis of the enclosing
if () statement.
