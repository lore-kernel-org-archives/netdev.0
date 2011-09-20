From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] add fec support for imx6q
Date: Tue, 20 Sep 2011 15:08:40 -0400 (EDT)
Message-ID: <20110920.150840.1516237043684327742.davem@davemloft.net>
References: <1316346852-17090-1-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	patches@linaro.org
To: shawn.guo@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49180 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750772Ab1ITTLw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2011 15:11:52 -0400
In-Reply-To: <1316346852-17090-1-git-send-email-shawn.guo@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shawn Guo <shawn.guo@linaro.org>
Date: Sun, 18 Sep 2011 19:54:08 +0800

> This series adds imx6q enet support.  The imx6q enet is a derivative of
> imx28 enet controller.  It fixed the frame endian issue found on imx28,
> and added 1 Gbps support.
> 
> It's based on v3.1-rc6.
> 
> Shawn Guo (4):
>       net/fec: change phy-reset-gpio request warning to debug message
>       net/fec: fix fec1 check in fec_enet_mii_init()
>       net/fec: set phy_speed to the optimal frequency 2.5 MHz
>       net/fec: add imx6q enet support

Please respin this against the net-next tree as that's where these
changes should be targetted and all the ethernet drivers have moved
to different directories in net-next.

Thanks.
