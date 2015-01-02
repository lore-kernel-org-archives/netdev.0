From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3][v2] net/fsl: remove hardcoded clock setting from
 xgmac_mdio
Date: Fri, 02 Jan 2015 15:40:25 -0500 (EST)
Message-ID: <20150102.154025.1422705995277492240.davem@davemloft.net>
References: <1419928101-2533-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Shaohui.Xie@freescale.com
To: shh.xie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52763 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752223AbbABUk1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 15:40:27 -0500
In-Reply-To: <1419928101-2533-1-git-send-email-shh.xie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <shh.xie@gmail.com>
Date: Tue, 30 Dec 2014 16:28:21 +0800

> From: Shaohui Xie <Shaohui.Xie@freescale.com>
> 
> There is no need to set the clock speed in read/write which will be performed
> unnecessarily for each mdio access. Init it during probe is enough.
> 
> Also, the hardcoded clock value is not a proper way for all SoCs.
> 
> Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>

Applied to net-next.
