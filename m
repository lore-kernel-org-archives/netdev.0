From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] enet: fec: fix fail resume from suspend state
Date: Tue, 26 Mar 2013 12:19:40 -0400 (EDT)
Message-ID: <20130326.121940.937673963522554506.davem@davemloft.net>
References: <1364264097-26157-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shawn.guo@linaro.org, lznuaa@gmail.com,
	u.kleine-koenig@pengutronix.de, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Frank.Li@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40164 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964887Ab3CZQTo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 12:19:44 -0400
In-Reply-To: <1364264097-26157-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Li <Frank.Li@freescale.com>
Date: Tue, 26 Mar 2013 10:14:57 +0800

> Without this patch
> 1. boot with nfs (no_console_suspend)
> 2. echo mem >/sys/power/state
> 3. wakeup by wakesource
> 4. print "eth0: tx queue full"
> 
> This fix above problem by reinit bd queue at restart function
> 
> Signed-off-by: Frank Li <Frank.Li@freescale.com>

Patch applies neither to 'net' nor 'net-next'.

Please respin this cleanly against current sources.
