From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] net: tlan: don't set unused function argument
Date: Thu, 16 Jun 2016 17:33:32 -0700 (PDT)
Message-ID: <20160616.173332.2040307459146830977.davem@davemloft.net>
References: <20160616113831.4108439-1-arnd@arndb.de>
	<20160616113831.4108439-3-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chessman@tux.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44624 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754297AbcFQAdd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 20:33:33 -0400
In-Reply-To: <20160616113831.4108439-3-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 16 Jun 2016 13:38:23 +0200

> We get a warning for tlan_handle_tx_eoc when building with "make W=1"
> 
> drivers/net/ethernet/ti/tlan.c: In function 'tlan_handle_tx_eoc':
> drivers/net/ethernet/ti/tlan.c:1647:59: error: parameter 'host_int' set but not used [-Werror=unused-but-set-parameter]
>  static u32 tlan_handle_tx_eoc(struct net_device *dev, u16 host_int)
> 
> This is harmless, but removing the unused assignment lets us avoid
> the warning with no downside.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied to net-next.
