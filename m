From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net resend] eth: fec: Fix lost promiscuous mode after
 reconnecting cable
Date: Thu, 13 Mar 2014 15:46:37 -0400 (EDT)
Message-ID: <20140313.154637.2019326790014536724.davem@davemloft.net>
References: <20140311.224834.40412164133780234.davem@davemloft.net>
	<1394620099-4509-1-git-send-email-stefan.wahren@i2se.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fugang.duan@freescale.com, lznuaa@gmail.com, festevam@gmail.com,
	netdev@vger.kernel.org, shawn.guo@linaro.org,
	Fabio.Estevam@freescale.com, Frank.Li@freescale.com,
	kernel@pengutronix.de
To: stefan.wahren@i2se.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55735 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754938AbaCMTqk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2014 15:46:40 -0400
In-Reply-To: <1394620099-4509-1-git-send-email-stefan.wahren@i2se.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Wahren <stefan.wahren@i2se.com>
Date: Wed, 12 Mar 2014 11:28:19 +0100

> If the Freescale fec is in promiscuous mode and network cable is
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

Applied, thank you.
