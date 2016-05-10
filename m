From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phylib: fix interrupts re-enablement in phy_start
Date: Tue, 10 May 2016 16:01:05 -0400 (EDT)
Message-ID: <20160510.160105.1924401488013786863.davem@davemloft.net>
References: <1462873346-46457-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com, Shaohui.Xie@nxp.com
To: shh.xie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43029 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751063AbcEJUBH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 16:01:07 -0400
In-Reply-To: <1462873346-46457-1-git-send-email-shh.xie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <shh.xie@gmail.com>
Date: Tue, 10 May 2016 17:42:26 +0800

> From: Shaohui Xie <Shaohui.Xie@nxp.com>
> 
> If phy was suspended and is starting, current driver always enable
> phy's interrupts, if phy works in polling, phy can raise unexpected
> interrupt which will not be handled, the interrupt will block system
> enter suspend again. So interrupts should only be re-enabled if phy
> works in interrupt.
> 
> Signed-off-by: Shaohui Xie <Shaohui.Xie@nxp.com>

Applied.
