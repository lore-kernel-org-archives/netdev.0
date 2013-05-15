From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] fec: Fix inconsistent lock state
Date: Wed, 15 May 2013 14:54:36 -0700 (PDT)
Message-ID: <20130515.145436.1654968585710381711.davem@davemloft.net>
References: <1368637587-13391-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shawn.guo@linaro.org, Frank.Li@freescale.com,
	kernel@pengutronix.de, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: fabio.estevam@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34012 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751354Ab3EOVyh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 May 2013 17:54:37 -0400
In-Reply-To: <1368637587-13391-1-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>
Date: Wed, 15 May 2013 14:06:26 -0300

> fec_restart() runs in softirq context and we should use the 
> netif_tx_lock_bh/netif_tx_unlock_bh() variants to avoid the following warning
> that happens since commit 54309fa6 ("net: fec: fix kernel oops when plug/unplug 
> cable many times"):
 ...
> Reported-by: Shawn Guo <shawn.guo@linaro.org>
> Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied.
