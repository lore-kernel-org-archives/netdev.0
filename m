From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] eth: fec: Fix lost promiscuous mode after
 reconnecting cable
Date: Tue, 11 Mar 2014 22:48:34 -0400 (EDT)
Message-ID: <20140311.224834.40412164133780234.davem@davemloft.net>
References: <f7c8b4dab2114552b919310c2a5bb444@BLUPR03MB373.namprd03.prod.outlook.com>
	<5319ED04.9070003@i2se.com>
	<531E0210.1090009@i2se.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fugang.duan@freescale.com, lznuaa@gmail.com, festevam@gmail.com,
	netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk,
	shawn.guo@linaro.org, Fabio.Estevam@freescale.com,
	Frank.Li@freescale.com, kernel@pengutronix.de
To: stefan.wahren@i2se.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33047 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751015AbaCLCsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 22:48:39 -0400
In-Reply-To: <531E0210.1090009@i2se.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Wahren <stefan.wahren@i2se.com>
Date: Mon, 10 Mar 2014 19:18:56 +0100

> If the Freescale i.MX28 fec is in promiscuous mode and network cable is
> reconnected then the promiscuous mode get lost. The problem is caused
> by a too soon call of set_multicast_list to re-enable promisc mode.
> The FEC_R_CNTRL register changes are overwritten by fec_restart.
> 
> This patch fixes this by moving the call behind the init of FEC_R_CNTRL
> register in fec_restart.
> 
> Successful tested on a i.MX28 board.
> 
> Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>

Your email client has corrupted your patch, making it unusable for us.

In particular, it has transformed TAB characters into spaces.

Please fix this and resubmit your patch, thank you.
