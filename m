From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/at91_ether: avoid NULL pointer dereference
Date: Mon, 07 Apr 2014 15:10:47 -0400 (EDT)
Message-ID: <20140407.151047.1262185364557499792.davem@davemloft.net>
References: <1396809464-22471-1-git-send-email-gilles.chanteperdrix@xenomai.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org
To: gilles.chanteperdrix@xenomai.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57196 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752718AbaDGTKt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 15:10:49 -0400
In-Reply-To: <1396809464-22471-1-git-send-email-gilles.chanteperdrix@xenomai.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gilles Chanteperdrix <gilles.chanteperdrix@xenomai.org>
Date: Sun,  6 Apr 2014 20:37:44 +0200

> The at91_ether driver calls macb_mii_init passing a 'struct macb'
> structure whose tx_clk member is initialized to 0. However,
> macb_handle_link_change() expects tx_clk to be the result of
> a call to clk_get, and so IS_ERR(tx_clk) to be true if the clock
> is invalid. This causes an oops when booting Linux 3.14 on the
> csb637 board. The following changes avoids this.
> 
> Signed-off-by: Gilles Chanteperdrix <gilles.chanteperdrix@xenomai.org>

Applied and queued up for -stable, thanks!
