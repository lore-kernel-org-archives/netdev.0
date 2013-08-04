From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net/phy: micrel: Add OF configuration support for
 ksz9021
Date: Sat, 03 Aug 2013 21:56:50 -0700 (PDT)
Message-ID: <20130803.215650.2298074538708777766.davem@davemloft.net>
References: <1375348757-12856-1-git-send-email-xobs@kosagi.com>
	<1375348757-12856-2-git-send-email-xobs@kosagi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: s.hauer@pengutronix.de, B38611@freescale.com,
	netdev@vger.kernel.org, devicetree@vger.kernel.org,
	stephen@networkplumber.org, rostedt@goodmis.org
To: xobs@kosagi.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56374 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751124Ab3HDE4v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Aug 2013 00:56:51 -0400
In-Reply-To: <1375348757-12856-2-git-send-email-xobs@kosagi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Cross <xobs@kosagi.com>
Date: Thu,  1 Aug 2013 09:19:17 +0000

> Some boards require custom PHY configuration, for example due to trace
> length differences.  Add the ability to configure these registers in
> order to get the PHY to function on boards that need it.
> 
> Because PHYs are auto-detected based on MDIO device IDs, allow PHY
> configuration to be specified in the parent Ethernet device node if no
> PHY device node is present.
> 
> Signed-off-by: Sean Cross <xobs@kosagi.com>

Can someone knowledgable in this area please review this patch?

Thanks.
