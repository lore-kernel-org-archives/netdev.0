From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/1] net: fec: fix phy reset operation to let imx6sl
 evk work
Date: Thu, 12 Sep 2013 17:12:51 -0400 (EDT)
Message-ID: <20130912.171251.883636431449078988.davem@davemloft.net>
References: <1378865937-12055-1-git-send-email-B38611@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shawn.guo@linaro.org, netdev@vger.kernel.org,
	bhutchings@solarflare.com, stephen@networkplumber.org,
	b20596@freescale.com, s.hauer@pengutronix.de
To: B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38580 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755502Ab3ILVMy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 17:12:54 -0400
In-Reply-To: <1378865937-12055-1-git-send-email-B38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <B38611@freescale.com>
Date: Wed, 11 Sep 2013 10:18:57 +0800

> Current driver only do phy reset in probe function, which is
> not right. Since some phy clock is disabled after module probe,
> the phy enter abnormal status, which needs do reset to recovery
> the phy. And do ifconfig ethx up/down test, the phy also enter
> abnormal status.

What would disable the PHY clock after the probe?

You have to explain these kinds of things in your changelog
message.

Thanks.
