From: David Miller <davem@davemloft.net>
Subject: Re: [patch-net-next 1/3] net: ethernet: cpsw: unroll IRQ request
 loop
Date: Wed, 14 Jan 2015 00:18:55 -0500 (EST)
Message-ID: <20150114.001855.480294380856199745.davem@davemloft.net>
References: <1421178288-7393-1-git-send-email-balbi@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tony@atomide.com, linux-omap@vger.kernel.org, mugunthanvnm@ti.com,
	netdev@vger.kernel.org
To: balbi@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39186 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748AbbANFTP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 00:19:15 -0500
In-Reply-To: <1421178288-7393-1-git-send-email-balbi@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felipe Balbi <balbi@ti.com>
Date: Tue, 13 Jan 2015 13:44:46 -0600

> +	ret = devm_request_irq(&pdev->dev, irq, cpsw_interrupt,
> +			0, dev_name(&pdev->dev), priv);

When a function call spans multiple lines, the argument on the second
and subsequent lines must start on the first column after the openning
parenthesis of the function call.

If you are using only TAB characters to indent, you are likely not
doing it correctly.

> +	ret = devm_request_irq(&pdev->dev, irq, cpsw_interrupt,
> +			0, dev_name(&pdev->dev), priv);

Likewise.

> +	ret = devm_request_irq(&pdev->dev, irq, cpsw_interrupt,
> +			0, dev_name(&pdev->dev), priv);

Likewise.

> +	ret = devm_request_irq(&pdev->dev, irq, cpsw_interrupt,
> +			0, dev_name(&pdev->dev), priv);

Likewise.
