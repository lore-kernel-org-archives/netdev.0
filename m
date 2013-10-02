From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] tg3: add support a phy at an address different
 than 01
Date: Wed, 02 Oct 2013 15:42:12 -0400 (EDT)
Message-ID: <20131002.154212.109589509619591563.davem@davemloft.net>
References: <1380402928-11480-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nsujir@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org
To: hauke@hauke-m.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48343 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753281Ab3JBTmR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 15:42:17 -0400
In-Reply-To: <1380402928-11480-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hauke Mehrtens <hauke@hauke-m.de>
Date: Sat, 28 Sep 2013 23:15:26 +0200

> When phylib was in use tg3 only searched at address 01 on the mdio
> bus and did not work with any other address. On the BCM4705 SoCs the
> switch is connected as a PHY behind the MAC driven by tg3 and it is at
> PHY address 30 in most cases. This is a preparation patch to allow
> support for such switches.
> 
> phy_addr is set to TG3_PHY_MII_ADDR for all devices, which are using
> phylib, so this should not change any behavior.
> 
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>

Applied to net-next.
