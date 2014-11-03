From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: fix suspend broken on multiple MACs sillicons
Date: Mon, 03 Nov 2014 14:50:38 -0500 (EST)
Message-ID: <20141103.145038.1224937667378001886.davem@davemloft.net>
References: <1414992410-27886-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, festevam@gmail.com
To: b38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48863 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753155AbaKCTum (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 14:50:42 -0500
In-Reply-To: <1414992410-27886-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <b38611@freescale.com>
Date: Mon, 3 Nov 2014 13:26:50 +0800

> On i.MX6SX sdb platform, there has two same enet MACs, after system up,
> just eth0 is up, and then do suspend/resume test:
 ...
> The root cause is that eth1 is not opened and clock is not enabled, and .suspend() still
> call .fec_enet_clk_enable() to disable clock.
> 
> To avoid the broken, let it check network device up status by calling .netif_running()
> before disable/enable clocks.
> 
> Signed-off-by: Fugang Duan <B38611@freescale.com>

Applied, thanks!
