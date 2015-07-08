From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] net: fec: Ensure clocks are enabled while using
 mdio bus
Date: Wed, 08 Jul 2015 15:59:29 -0700 (PDT)
Message-ID: <20150708.155929.1434545787077533626.davem@davemloft.net>
References: <1436207695-652-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fugang.duan@freescale.com, cory.tusar@pid1solutions.com,
	netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38155 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751014AbbGHW7a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 18:59:30 -0400
In-Reply-To: <1436207695-652-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Mon,  6 Jul 2015 20:34:55 +0200

> When a switch is attached to the mdio bus, the mdio bus can be used
> while the interface is not open. If the IPG clock is not enabled, MDIO
> reads/writes will simply time out.
> 
> Add support for runtime PM to control this clock. Enable/disable this
> clock using runtime PM, with open()/close() and mdio read()/write()
> function triggering runtime PM operations. Since PM is optional, the
> IPG clock is enabled at probe and is no longer modified by
> fec_enet_clk_enable(), thus if PM is not enabled in the kernel, it is
> guaranteed the clock is running when MDIO operations are performed.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
> v5:
> Rewrite to use runtime PM with fec_runtime_suspend and fec_runtime_resume

Applied, thanks.
