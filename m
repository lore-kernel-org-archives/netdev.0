From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next 2/4] net: fec: add interrupt coalescence
 feature support
Date: Mon, 15 Sep 2014 17:34:08 -0400 (EDT)
Message-ID: <20140915.173408.1107708227801679897.davem@davemloft.net>
References: <1410801177-15872-1-git-send-email-Frank.Li@freescale.com>
	<1410801177-15872-3-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: b38611@freescale.com, netdev@vger.kernel.org, lznuaa@gmail.com,
	shawn.guo@linaro.org, linux-arm-kernel@lists.infradead.org
To: Frank.Li@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40013 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754111AbaIOVeL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 17:34:11 -0400
In-Reply-To: <1410801177-15872-3-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Frank.Li@freescale.com>
Date: Tue, 16 Sep 2014 01:12:55 +0800

>  	unsigned int tx_align;
>  	unsigned int rx_align;
> +
> +	/* hw interrupt coalesce */
> +	uint rx_pkts_itr;
> +	uint rx_time_itr;
> +	uint tx_pkts_itr;
> +	uint tx_time_itr;

Please use explicit "unsigned int" just like the lines right above the ones
you are adding.

> +	/* Must be greater than zero to avoid unpredictable behavior */
> +	if (!fep->rx_time_itr || !fep->rx_pkts_itr ||
> +		!fep->tx_time_itr || !fep->tx_pkts_itr)

This is not indented properly.

On the second and subsequent lines of a multi-line conditional, things
must start exactly at the first column after the openning parenthesis
of the first line.
