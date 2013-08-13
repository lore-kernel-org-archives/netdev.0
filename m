From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-next v2] gianfar: Add flow control support
Date: Tue, 13 Aug 2013 15:29:16 -0700 (PDT)
Message-ID: <20130813.152916.1256175758105854594.davem@davemloft.net>
References: <1376068786-29868-1-git-send-email-claudiu.manoil@freescale.com>
	<1376304806-8504-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	ljaenicke@innominate.com
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44897 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759214Ab3HMW3R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 18:29:17 -0400
In-Reply-To: <1376304806-8504-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Mon, 12 Aug 2013 13:53:26 +0300

> eTSEC has Rx and Tx flow control capabilities that may be enabled
> through MACCFG1[Rx_Flow, Tx_Flow] bits.  These bits must not be set
> however when eTSEC is operated in Half-Duplex mode.  Unfortunately,
> the driver currently sets these bits unconditionally.
> This patch adds the proper handling of the PAUSE frame capability
> register bits by implementing the ethtool -A interface.  When pause
> autoneg is enabled, the controller uses the phy's capability to
> negotiate PAUSE frame settings with the link partner and reconfigures
> its Rx_Flow and Tx_Flow settings to match the capabilities of the
> link partner.  If pause autoneg is off, the PAUSE frame generation
> may be forced manually (ethtool -A).  Flow control is disabled by
> default now.
> This implementation is inspired by the tg3 driver.
> 
> Signed-off-by: Lutz Jaenicke <ljaenicke@innominate.com>
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>

Applied to net-next, thanks.
