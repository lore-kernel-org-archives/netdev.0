From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/1 net] enet: fec: fix fail resume from suspend
 state
Date: Wed, 27 Mar 2013 14:09:45 -0400 (EDT)
Message-ID: <20130327.140945.1084520243407747388.davem@davemloft.net>
References: <1364350323-2488-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shawn.guo@linaro.org, lznuaa@gmail.com,
	u.kleine-koenig@pengutronix.de, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Frank.Li@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58870 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751540Ab3C0SJt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 14:09:49 -0400
In-Reply-To: <1364350323-2488-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Li <Frank.Li@freescale.com>
Date: Wed, 27 Mar 2013 10:12:03 +0800

> Without this patch
> 1. boot with nfs (no_console_suspend)
> 2. echo mem >/sys/power/state
> 3. wakeup by wakesource
> 4. print "eth0: tx queue full"
> 
> This fix above problem by reinit bd queue at restart function
> 
> Signed-off-by: Frank Li <Frank.Li@freescale.com>

Applied.
