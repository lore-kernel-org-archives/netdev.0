From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] net: fec: TX Buffer incorrectly
 initialized
Date: Tue, 26 Mar 2013 12:56:06 -0400 (EDT)
Message-ID: <20130326.125606.1823213005322090680.davem@davemloft.net>
References: <y>
	<1364311507-7489-1-git-send-email-jim_baxter@mentor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Frank.Li@freescale.com, fabio.estevam@freescale.com,
	netdev@vger.kernel.org
To: jim_baxter@mentor.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41189 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751862Ab3CZQ4I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 12:56:08 -0400
In-Reply-To: <1364311507-7489-1-git-send-email-jim_baxter@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jim Baxter <jim_baxter@mentor.com>
Date: Tue, 26 Mar 2013 15:25:07 +0000

> The TX Buffer in fec_enet_alloc_buffers was being initialized
> with the receive register define BD_ENET_RX_INT instead of
> the transmit register define BD_ENET_TX_INT
> 
> Signed-off-by: Jim Baxter <jim_baxter@mentor.com>

Applied.
