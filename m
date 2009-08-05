From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] cpmac: fix wrong MDIO bus identifier
Date: Wed, 05 Aug 2009 12:23:26 -0700 (PDT)
Message-ID: <20090805.122326.53960211.davem@davemloft.net>
References: <200908042252.42254.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54665
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750734AbZHETXR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 15:23:17 -0400
In-Reply-To: <200908042252.42254.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Tue, 4 Aug 2009 22:52:41 +0200

> This patch fixes the wrong MDIO bus identifier which was
> set to 0 unconditionaly, suitable for external switches while
> it is actually 1 for PHYs different than external switches
> which are autodetected.
> 
> Signed-off-by: Florian Fainelli <florian@openwrt.org>

Applied to net-next-2.6
