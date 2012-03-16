From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] net: sh_eth: add CONFIG_SH_ETH_NUM_RXDESC option
Date: Fri, 16 Mar 2012 02:11:17 -0700 (PDT)
Message-ID: <20120316.021117.1280920754044065090.davem@davemloft.net>
References: <4F62FDD8.9010907@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: yoshihiro.shimoda.uh@renesas.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36494 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757556Ab2CPJLV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2012 05:11:21 -0400
In-Reply-To: <4F62FDD8.9010907@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Date: Fri, 16 Mar 2012 17:46:16 +0900

> This patch allows you to configure the number of RX descriptors.
> 
> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>

Never decide such things at compile time, use ethtool at runtime
for this.
