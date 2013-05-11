From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: enable hardware checksum only on imx6q-fec
Date: Sat, 11 May 2013 16:12:57 -0700 (PDT)
Message-ID: <20130511.161257.1222305719812815291.davem@davemloft.net>
References: <1368083302-12516-1-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jim_baxter@mentor.com, kernel@pengutronix.de,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: shawn.guo@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60179 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220Ab3EKXM6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 May 2013 19:12:58 -0400
In-Reply-To: <1368083302-12516-1-git-send-email-shawn.guo@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shawn Guo <shawn.guo@linaro.org>
Date: Thu, 9 May 2013 15:08:22 +0800

> Commit 4c09eed (net: fec: Enable imx6 enet checksum acceleration.)
> enables hardware checksum acceleration unconditionally for all fec
> variants.  This is inappropriate, because some variants like imx5 have
> no such support on hardware.  Consequently, fec is broken on these
> platforms.  Fix it by enabling hardware checksum only on imx6q-fec type
> of controllers.
> 
> Signed-off-by: Shawn Guo <shawn.guo@linaro.org>

Applied.
