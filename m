From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] cpmac: wait longer after MDIO reset
Date: Wed, 05 Aug 2009 12:23:49 -0700 (PDT)
Message-ID: <20090805.122349.80542560.davem@davemloft.net>
References: <200908042252.57848.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54677
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751864AbZHETXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 15:23:40 -0400
In-Reply-To: <200908042252.57848.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Tue, 4 Aug 2009 22:52:57 +0200

> This patch slows down the MDIO_ALIVE busy waiting to let
> switches and PHY come up after reset. Previous loop was
> too quick for IC+175C and ADM6996C/L switches to come up.
> 
> Signed-off-by: Florian Fainelli <florian@openwrt.org>

Applied to net-next-2.6
