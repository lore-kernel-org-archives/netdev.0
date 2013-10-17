From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ethernet: cpsw: Bugfix interrupts before enabling
 napi
Date: Thu, 17 Oct 2013 15:48:44 -0400 (EDT)
Message-ID: <20131017.154844.1958017973482686300.davem@davemloft.net>
References: <1381691821-25498-1-git-send-email-mpa@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: florian@openwrt.org, mugunthanvnm@ti.com, peter@korsgaard.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	kernel@pengutronix.de
To: mpa@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46593 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758245Ab3JQTsr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 15:48:47 -0400
In-Reply-To: <1381691821-25498-1-git-send-email-mpa@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Pargmann <mpa@pengutronix.de>
Date: Sun, 13 Oct 2013 21:17:01 +0200

> If interrupts happen before napi_enable was called, the driver will not
> work as expected. Network transmissions are impossible in this state.
> This bug can be reproduced easily by restarting the network interface in
> a loop. After some time any network transmissions on the network
> interface will fail.
> 
> This patch fixes the bug by enabling napi before enabling the network
> interface interrupts.
> 
> Signed-off-by: Markus Pargmann <mpa@pengutronix.de>

Applied, thanks.
