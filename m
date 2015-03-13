From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/macb: Only adjust tx_clk on link change
Date: Thu, 12 Mar 2015 23:04:45 -0400 (EDT)
Message-ID: <20150312.230445.1330829248378823525.davem@davemloft.net>
References: <1426201674-824-1-git-send-email-jaeden.amero@ni.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, joshc@ni.com,
	soren.brinkmann@xilinx.com
To: jaeden.amero@ni.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43642 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753210AbbCMDEr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 23:04:47 -0400
In-Reply-To: <1426201674-824-1-git-send-email-jaeden.amero@ni.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jaeden Amero <jaeden.amero@ni.com>
Date: Thu, 12 Mar 2015 18:07:54 -0500

> The PHY state machine (in drivers/net/phy/phy.c) will unconditionally
> call phydev->adjust_link (macb_handle_link_change) when polling in the
> PHY_CHANGELINK state. As currently written, macb always ends up
> requesting a new tx_clk frequency in macb_handle_link_change. It is a
> waste of time to request a new tx_clk frequency if the link state hasn't
> changed, as the tx_clk will already be configured properly.
> 
> Let's only request a new tx_clk clock frequency when necessary.
> 
> Signed-off-by: Jaeden Amero <jaeden.amero@ni.com>

Applied to net-next, thanks.
