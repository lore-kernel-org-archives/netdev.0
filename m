From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Revert "net: fec: Ensure clocks are enabled while
 using mdio bus"
Date: Mon, 13 Jul 2015 13:08:04 -0700 (PDT)
Message-ID: <20150713.130804.1129494283244919678.davem@davemloft.net>
References: <1436786032-7533-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: B38611@freescale.com, andrew@lunn.ch, shawn.guo@linaro.org,
	tyler.baker@linaro.org, netdev@vger.kernel.org
To: fabio.estevam@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43781 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752588AbbGMUIG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 16:08:06 -0400
In-Reply-To: <1436786032-7533-1-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>
Date: Mon, 13 Jul 2015 08:13:52 -0300

> This reverts commit 6c3e921b18edca290099adfddde8a50236bf2d80.
> 
> commit 6c3e921b18ed ("net: fec: Ensure clocks are enabled while using mdio
>  bus") prevents the kernel to boot on mx6 boards, so let's revert it.
> 
> Reported-by: Tyler Baker <tyler.baker@linaro.org>
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Andrew, please review.
