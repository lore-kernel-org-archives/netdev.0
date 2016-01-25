From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: fec: use CONFIG_ARM instead of
 CONFIG_ARCH_MXC/SOC_IMX28
Date: Mon, 25 Jan 2016 10:52:46 -0800 (PST)
Message-ID: <20160125.105246.1024464437188963991.davem@davemloft.net>
References: <1453718450-7250-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gerg@uclinux.org, l.stach@pengutronix.de,
	B38611@freescale.com, arnd@arndb.de, shawnguo@kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49154 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757539AbcAYSwr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2016 13:52:47 -0500
In-Reply-To: <1453718450-7250-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Mon, 25 Jan 2016 11:40:50 +0100

> As Arnd Bergmann points out, using CONFIG_ARCH_MXC and/or SOC_IMX28
> is wrong if some other ARM platform uses this device - the operation
> of the driver would depend on an unrelated ARM platform that might
> or might not be set for multi-platform kernels.
> 
> Prior to my previous patch, any other platforms using it would have
> been broken already due to having the cbd_datlen/cbd_sc fields in
> the wrong order, but byte ordering correctly, so no such platforms
> can exist and work today.
> 
> In any case, it seems likely that only Freescale SoCs use this part,
> and those are little-endian on ARM, so CONFIG_ARM is safe for them.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

Applied.
