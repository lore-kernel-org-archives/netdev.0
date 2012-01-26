From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V5 1/4] CS89x0 : add platform driver support
Date: Thu, 26 Jan 2012 17:49:51 -0500 (EST)
Message-ID: <20120126.174951.1458396120409651458.davem@davemloft.net>
References: <1327610775-26893-1-git-send-email-jaccon.bastiaansen@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel@pengutronix.de, u.kleine-koenig@pengutronix.de,
	s.hauer@pengutronix.de, cavokz@gmail.com, linux@arm.linux.org.uk,
	fabio.estevam@freescale.com, festevam@gmail.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: jaccon.bastiaansen@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35651 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751963Ab2AZWyX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2012 17:54:23 -0500
In-Reply-To: <1327610775-26893-1-git-send-email-jaccon.bastiaansen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
Date: Thu, 26 Jan 2012 21:46:15 +0100

> The CS89x0 ethernet controller is used on a number of evaluation
> boards, such as the MX31ADS. The current driver has memory address and
> IRQ settings for each board on which this controller is used. Driver
> updates are therefore required to support other boards that also use
> the CS89x0. To avoid these driver updates, a better mechanism
> (platform driver support) is added to communicate the board dependent
> settings to the driver.
> 
> Signed-off-by: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>

I'm fine with this going via one of the ARM trees:

Acked-by: David S. Miller <davem@davemloft.net>
