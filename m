From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next 1/4] net: fec: refine error handle of parser
 queue number from DT
Date: Mon, 15 Sep 2014 17:32:47 -0400 (EDT)
Message-ID: <20140915.173247.59215420475562894.davem@davemloft.net>
References: <1410801177-15872-1-git-send-email-Frank.Li@freescale.com>
	<1410801177-15872-2-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: b38611@freescale.com, netdev@vger.kernel.org, lznuaa@gmail.com,
	shawn.guo@linaro.org, linux-arm-kernel@lists.infradead.org
To: Frank.Li@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39969 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755369AbaIOVcu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 17:32:50 -0400
In-Reply-To: <1410801177-15872-2-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Frank.Li@freescale.com>
Date: Tue, 16 Sep 2014 01:12:54 +0800

> -		dev_err(&pdev->dev, "Invalidate num_tx(=%d), fail back to 1\n",
> +		dev_warn(&pdev->dev, "Invalid num_tx(=%d), fall back to 1\n",
>  			*num_tx);

Any time you change the function name of a multi-line function call, you must
be mindful to adjust the indention of the subsequent argument lines, if
necessary.

>  	if (*num_rx < 1 || *num_rx > FEC_ENET_MAX_RX_QS) {
> -		dev_err(&pdev->dev, "Invalidate num_rx(=%d), fail back to 1\n",
> +		dev_warn(&pdev->dev, "Invalid num_rx(=%d), fall back to 1\n",
>  			*num_rx);

Likewise.
