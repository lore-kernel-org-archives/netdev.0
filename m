From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2 net-next] net: fec: fix miss init spinlock
Date: Wed, 06 Feb 2013 15:04:31 -0500 (EST)
Message-ID: <20130206.150431.408313770070806281.davem@davemloft.net>
References: <1360045577-6266-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lznuaa@gmail.com, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, shawn.guo@linaro.org, B38611@freescale.com,
	s.hauer@pengutronix.de
To: Frank.Li@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43087 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758193Ab3BFUEd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 15:04:33 -0500
In-Reply-To: <1360045577-6266-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Li <Frank.Li@freescale.com>
Date: Tue, 5 Feb 2013 14:26:16 +0800

> Change from v1 to v2
>  - avoid reinit hwreg_lock twice

I already applied your v1 patch, so you have to revert that spin_lock_init()
call in this change.

Please do that and respin this patch series.
