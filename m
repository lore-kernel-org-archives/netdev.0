From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/fsl: fix a bug in xgmac_mdio
Date: Tue, 13 Jan 2015 16:43:59 -0500 (EST)
Message-ID: <20150113.164359.1174451979198450960.davem@davemloft.net>
References: <1421116231-16100-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Shaohui.Xie@freescale.com
To: shh.xie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36454 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752729AbbAMVoB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 16:44:01 -0500
In-Reply-To: <1421116231-16100-1-git-send-email-shh.xie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <shh.xie@gmail.com>
Date: Tue, 13 Jan 2015 10:30:31 +0800

> From: Shaohui Xie <Shaohui.Xie@freescale.com>
> 
> There is a bug in xgmac_mdio_read when clear the bit MDIO_STAT_ENC,
> which '&' is missed in 'mdio_stat &= ~MDIO_STAT_ENC'.
> 
> Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>

Applied.
