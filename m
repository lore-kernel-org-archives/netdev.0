From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/8] net: gianfar: fix old-style declaration
Date: Thu, 16 Jun 2016 22:06:49 -0700 (PDT)
Message-ID: <20160616.220649.708653313475009092.davem@davemloft.net>
References: <20160616135020.3154461-1-arnd@arndb.de>
	<20160616135245.3198419-1-arnd@arndb.de>
	<20160616135245.3198419-6-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yangbo.lu@nxp.com,
	linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160616135245.3198419-6-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 16 Jun 2016 15:52:13 +0200

> Modern C standards expect the '__inline__' keyword to come before the return
> type in a declaration, and we get a warning for this with "make W=1":
> 
> drivers/net/ethernet/freescale/gianfar.c:2278:1: error: 'inline' is not at beginning of declaration [-Werror=old-style-declaration]
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
