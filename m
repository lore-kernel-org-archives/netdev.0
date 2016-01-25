From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2] net: fec: use CONFIG_ARM instead of CONFIG_ARCH_MXC/SOC_IMX28
Date: Mon, 25 Jan 2016 11:43:43 +0100
Message-ID: <1612772.4retUf0a0d@wuerfel>
References: <1453718450-7250-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, Greg Ungerer <gerg@uclinux.org>,
	Lucas Stach <l.stach@pengutronix.de>,
	Fugang Duan <B38611@freescale.com>,
	Shawn Guo <shawnguo@kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.135]:52404 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932353AbcAYKoF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2016 05:44:05 -0500
In-Reply-To: <1453718450-7250-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 25 January 2016 11:40:50 Johannes Berg wrote:
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
> 

Thanks, looks good.

Reviewed-by: Arnd Bergmann <arnd@arndb.de>
