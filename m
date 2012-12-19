From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: forbid FEC_PTP on SoCs that do not support
Date: Tue, 18 Dec 2012 16:26:56 -0800 (PST)
Message-ID: <20121218.162656.1759253364857674480.davem@davemloft.net>
References: <1355836004-22067-1-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, s.hauer@pengutronix.de,
	richardcochran@gmail.com
To: shawn.guo@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37698 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755068Ab2LSA05 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 19:26:57 -0500
In-Reply-To: <1355836004-22067-1-git-send-email-shawn.guo@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shawn Guo <shawn.guo@linaro.org>
Date: Tue, 18 Dec 2012 21:06:44 +0800

> Beside imx6q, the kernel built from imx_v6_v7_defconfig is also
> supposed to be running on other IMX SoCs that do not have the PTP
> block.  Before fec driver gets fixed to run-time detect target hardware
> rather than conditional compiling with #ifdef CONFIG_FEC_PTP, let's
> give it a quick fix in Kconfig to forbid FEC_PTP on those IMX SoCs that
> do not support PTP.
> 
> Reported-by: Sascha Hauer <s.hauer@pengutronix.de>
> Signed-off-by: Shawn Guo <shawn.guo@linaro.org>

This uglyness is exactly why this needs to be detected at run
time.

Anyways, applied.
