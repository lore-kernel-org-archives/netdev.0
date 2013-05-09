From: Jim Baxter <jim_baxter@mentor.com>
Subject: Re: [PATCH] net: fec: enable hardware checksum only on imx6q-fec
Date: Thu, 9 May 2013 10:35:15 +0100
Message-ID: <518B6DD3.1040201@mentor.com>
References: <1368083302-12516-1-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <kernel@pengutronix.de>,
	<netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>
To: Shawn Guo <shawn.guo@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:38029 "EHLO
	relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753461Ab3EIJf0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 May 2013 05:35:26 -0400
In-Reply-To: <1368083302-12516-1-git-send-email-shawn.guo@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/05/13 08:08, Shawn Guo wrote:
> Commit 4c09eed (net: fec: Enable imx6 enet checksum acceleration.)
> enables hardware checksum acceleration unconditionally for all fec
> variants.  This is inappropriate, because some variants like imx5 have
> no such support on hardware.  Consequently, fec is broken on these
> platforms.  Fix it by enabling hardware checksum only on imx6q-fec type
> of controllers.
> 
> Signed-off-by: Shawn Guo <shawn.guo@linaro.org>

Reviewed-by: Jim Baxter <jim_baxter@mentor.com>
