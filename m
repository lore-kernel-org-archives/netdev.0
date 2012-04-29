From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] drivers/net/oki-semi: Remove the
 definition of PCH_GBE_ETH_ALEN
Date: Sat, 28 Apr 2012 22:00:14 -0400 (EDT)
Message-ID: <20120428.220014.1885704725231159526.davem@davemloft.net>
References: <1335510073-14018-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54620 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755760Ab2D2CAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2012 22:00:17 -0400
In-Reply-To: <1335510073-14018-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Fri, 27 Apr 2012 15:01:12 +0800

> From: RongQing.Li <roy.qing.li@gmail.com>
> 
> PCH_GBE_ETH_ALEN is equal to ETH_ALEN, so we can replace it with
> ETH_ALEN.
> 
> If they are not equal, it must be a bug, since this is ethernet,
> and the address has been already stored to mc_addr_list as ETH_ALEN
> bytes when call pch_gbe_mac_mc_addr_list_update.
> 
> Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>

Applied.
