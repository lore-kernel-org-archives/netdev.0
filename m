From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: au1000_eth: fix PHY detection
Date: Fri, 10 Jun 2016 23:32:45 -0700 (PDT)
Message-ID: <20160610.233245.1299890221213815189.davem@davemloft.net>
References: <20160610145305.665482-1-manuel.lauss@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com, andrew@lunn.ch
To: manuel.lauss@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35274 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751171AbcFKGcq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2016 02:32:46 -0400
In-Reply-To: <20160610145305.665482-1-manuel.lauss@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manuel Lauss <manuel.lauss@gmail.com>
Date: Fri, 10 Jun 2016 16:53:05 +0200

> Commit 7f854420fbfe9d49afe2ffb1df052cfe8e215541
> ("phy: Add API for {un}registering an mdio device to a bus.")
> broke PHY detection on this driver with a copy-paste bug:
> The code is looking 32 times for a PHY at address 0.
> 
> Fixes ethernet on AMD DB1100/DB1500/DB1550 boards which have
> their (autodetected) PHYs at address 31.
> 
> Cc: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Manuel Lauss <manuel.lauss@gmail.com>

Applied.
