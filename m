From: Shawn Guo <shawn.guo@linaro.org>
Subject: Re: [PATCH 1/1] enet: fec: fix fail resume from suspend state
Date: Tue, 26 Mar 2013 11:46:56 +0800
Message-ID: <20130326034653.GA5148@S2101-09.ap.freescale.net>
References: <1364264097-26157-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <lznuaa@gmail.com>, <u.kleine-koenig@pengutronix.de>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>
To: Frank Li <Frank.Li@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe004.messaging.microsoft.com ([207.46.163.27]:59825
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756889Ab3CZDqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 23:46:12 -0400
Content-Disposition: inline
In-Reply-To: <1364264097-26157-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 26, 2013 at 10:14:57AM +0800, Frank Li wrote:
> Without this patch
> 1. boot with nfs (no_console_suspend)
> 2. echo mem >/sys/power/state
> 3. wakeup by wakesource
> 4. print "eth0: tx queue full"
> 
> This fix above problem by reinit bd queue at restart function
> 
> Signed-off-by: Frank Li <Frank.Li@freescale.com>

On imx6q and imx28,

Tested-by: Shawn Guo <shawn.guo@linaro.org>
