From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/phy: fix mdio-octeon dependency and build
Date: Wed, 24 May 2017 15:48:23 -0400 (EDT)
Message-ID: <20170524.154823.1783635748700387033.davem@davemloft.net>
References: <c37b4171-e3f2-c5cc-d734-6e1688c964f5@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch, f.fainelli@gmail.com,
        linux-kernel@vger.kernel.org
To: rdunlap@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49640 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934566AbdEXTsZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 15:48:25 -0400
In-Reply-To: <c37b4171-e3f2-c5cc-d734-6e1688c964f5@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <rdunlap@infradead.org>
Date: Tue, 23 May 2017 08:19:49 -0700

> From: Randy Dunlap <rdunlap@infradead.org>
> 
> Fix build errors by making this driver depend on OF_MDIO, like
> several other similar drivers do.
> 
> drivers/built-in.o: In function `octeon_mdiobus_remove':
> mdio-octeon.c:(.text+0x196ee0): undefined reference to `mdiobus_unregister'
> mdio-octeon.c:(.text+0x196ee8): undefined reference to `mdiobus_free'
> drivers/built-in.o: In function `octeon_mdiobus_probe':
> mdio-octeon.c:(.text+0x196f1d): undefined reference to `devm_mdiobus_alloc_size'
> mdio-octeon.c:(.text+0x196ffe): undefined reference to `of_mdiobus_register'
> mdio-octeon.c:(.text+0x197010): undefined reference to `mdiobus_free'
> 
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>

Applied, thanks Randy.
