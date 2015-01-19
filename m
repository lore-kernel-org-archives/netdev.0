From: David Miller <davem@davemloft.net>
Subject: Re: [patch-net-next v3] net: ethernet: ti: cpsw: fix buld break
 when NET_POLL_CONTROLLER
Date: Mon, 19 Jan 2015 14:45:18 -0500 (EST)
Message-ID: <20150119.144518.396869631568771714.davem@davemloft.net>
References: <1421689956-14369-1-git-send-email-balbi@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tony@atomide.com, linux-omap@vger.kernel.org, mugunthanvnm@ti.com,
	netdev@vger.kernel.org
To: balbi@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33463 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751916AbbASTpY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 14:45:24 -0500
In-Reply-To: <1421689956-14369-1-git-send-email-balbi@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felipe Balbi <balbi@ti.com>
Date: Mon, 19 Jan 2015 11:52:36 -0600

> Commit c03abd84634d (net: ethernet: cpsw: don't requests IRQs we don't
> use) left one build breakage when NET_POLL_CONTROLLER is enabled.
> 
> Fix this build break by referring to the correct irqs_table array.
> 
> Fixes: c03abd84634d (net: ethernet: cpsw: don't requests IRQs we don't use)
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Felipe Balbi <balbi@ti.com>

Applied, thanks.
