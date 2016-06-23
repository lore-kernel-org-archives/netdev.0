From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: b53: Fix statistics readings
Date: Thu, 23 Jun 2016 15:20:27 -0400 (EDT)
Message-ID: <20160623.152027.389647299887184166.davem@davemloft.net>
References: <1466472413-25824-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com, jogo@openwrt.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34917 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750950AbcFWTUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 15:20:35 -0400
In-Reply-To: <1466472413-25824-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 20 Jun 2016 18:26:53 -0700

> Due to a typo we would always be using the MIB counter width of the
> first element of the counter array instead of the current element, and
> we would always be accessing the register statistics with a 64-bits
> read, while some could be 32-bits. This got unnoticed in testing with
> MDIO and SRAB which tolerate doing this, but testing with the SPI bus
> revealed bogus values being returned. Fix this by using the proper
> iterator here.
> 
> Fixes: 967dd82ffc52 ("net: dsa: b53: Add support for Broadcom RoboSwitch")
> Reported-by: Jonas Gorski <jogo@openwrt.org>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied.
