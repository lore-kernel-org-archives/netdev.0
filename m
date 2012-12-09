From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next #2 1/1] r8169: workaround for missing extended
 GigaMAC registers
Date: Sun, 09 Dec 2012 00:32:02 -0500 (EST)
Message-ID: <20121209.003202.2081907040446274601.davem@davemloft.net>
References: <20121207212021.GA8412@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jlee@suse.com, udknight@gmail.com,
	hayeswang@realtek.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42133 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750873Ab2LIFcE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Dec 2012 00:32:04 -0500
In-Reply-To: <20121207212021.GA8412@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Fri, 7 Dec 2012 22:20:21 +0100

> GigaMAC registers have been reported left unitialized in several
> situations:
> - after cold boot from power-off state
> - after S3 resume
> 
> Tweaking rtl_hw_phy_config takes care of both.
> 
> This patch removes an excess entry (",") at the end of the exgmac_reg
> array as well.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Signed-off-by: Wang YanQing <udknight@gmail.com>
> Cc: Hayes Wang <hayeswang@realtek.com>

Applied, thanks.
