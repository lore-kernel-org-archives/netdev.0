From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: fec: fix rcv is not last issue when do
 suspend/resume test
Date: Wed, 04 Mar 2015 15:57:20 -0500 (EST)
Message-ID: <20150304.155720.1848596405389862350.davem@davemloft.net>
References: <1425426763-23361-1-git-send-email-peter.chen@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b38611@freescale.com,
	stable@vger.kernel.org
To: peter.chen@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49505 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751116AbbCDU5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 15:57:22 -0500
In-Reply-To: <1425426763-23361-1-git-send-email-peter.chen@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Chen <peter.chen@freescale.com>
Date: Wed, 4 Mar 2015 07:52:11 +0800

> From: Fugang Duan <b38611@freescale.com>
> 
> When do suspend/resume stress test, some log shows "rcv is not +last".
> The issue is that enet suspend will disable phy clock, phy link down,
> after resume back, enet MAC redo initial and ready to tx/rx packet,
> but phy still is not ready which is doing auto-negotiation. When phy
> link is not up, don't schdule napi soft irq.
> 
...
> Tested-by: Peter Chen <peter.chen@freescale.com>
> Signed-off-by: Peter Chen <peter.chen@freescale.com>
> Signed-off-by: Fugang Duan <B38611@freescale.com>

Applied, thanks.
