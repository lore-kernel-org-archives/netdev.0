From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/phy: micrel: Add clock support for
 KSZ8021/KSZ8031
Date: Fri, 10 Oct 2014 15:36:05 -0400 (EDT)
Message-ID: <20141010.153605.275901680055082156.davem@davemloft.net>
References: <1412927285-6809-1-git-send-email-s.hauer@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel@pengutronix.de
To: s.hauer@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56425 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751703AbaJJTgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 15:36:07 -0400
In-Reply-To: <1412927285-6809-1-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sascha Hauer <s.hauer@pengutronix.de>
Date: Fri, 10 Oct 2014 09:48:05 +0200

> The KSZ8021 and KSZ8031 support RMII reference input clocks of 25MHz
> and 50MHz. Both PHYs differ in the default frequency they expect
> after reset. If this differs from the actual input clock, then
> register 0x1f bit 7 must be changed.
> 
> Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>

Applied, thanks.
