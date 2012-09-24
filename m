From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3 V4] phy/micrel: Implement support for KSZ8021
Date: Mon, 24 Sep 2012 16:00:45 -0400 (EDT)
Message-ID: <20120924.160045.1121470029613315168.davem@davemloft.net>
References: <1348455531-24371-1-git-send-email-marex@denx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, david.choi@micrel.com,
	nobuhiro.iwamatsu.yj@renesas.com
To: marex@denx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53833 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757679Ab2IXUAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 16:00:48 -0400
In-Reply-To: <1348455531-24371-1-git-send-email-marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Vasut <marex@denx.de>
Date: Mon, 24 Sep 2012 04:58:49 +0200

> The KSZ8021 PHY was previously caught by KS8051, which is not correct.
> This PHY needs additional setup if it is strapped for address 0. In such
> case an reserved bit must be written in the 0x16, "Operation Mode Strap
> Override" register. According to the KS8051 datasheet, that bit means
> "PHY Address 0 in non-broadcast" and it indeed behaves as such on KSZ8021.
> The issue where the ethernet controller (Freescale FEC) did not communicate
> with network is fixed by writing this bit as 1.
> 
> Signed-off-by: Marek Vasut <marex@denx.de>

Applied.
