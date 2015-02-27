From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: macb: Add big endian CPU support
Date: Fri, 27 Feb 2015 17:24:30 -0500 (EST)
Message-ID: <20150227.172430.705343480463996651.davem@davemloft.net>
References: <54EEF9C6.8070701@monstr.eu>
	<1424948474-11872-1-git-send-email-achandran@mvista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, monstr@monstr.eu
To: achandran@mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54802 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755519AbbB0WYd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 17:24:33 -0500
In-Reply-To: <1424948474-11872-1-git-send-email-achandran@mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arun Chandran <achandran@mvista.com>
Date: Thu, 26 Feb 2015 16:31:14 +0530

> This patch converts all __raw_readl and __raw_writel function calls
> to their corresponding readl_relaxed and writel_relaxed variants.
> 
> It also tells the driver to set ahb_endian_swp_mgmt_en bit in dma_cfg
> when the CPU is configured in big endian mode.
> 
> Signed-off-by: Arun Chandran <achandran@mvista.com>

This does not apply cleanly to net-next, please respin.
