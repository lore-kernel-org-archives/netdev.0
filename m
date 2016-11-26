From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] mvpp2: use correct size for memset
Date: Fri, 25 Nov 2016 20:57:35 -0500 (EST)
Message-ID: <20161125.205735.849551572881291744.davem@davemloft.net>
References: <20161124162843.3849988-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jszhang@marvell.com, mw@semihalf.com, tremyfr@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58996 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752478AbcKZB5h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 20:57:37 -0500
In-Reply-To: <20161124162843.3849988-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 24 Nov 2016 17:28:12 +0100

> gcc-7 detects a short memset in mvpp2, introduced in the original
> merge of the driver:
> 
> drivers/net/ethernet/marvell/mvpp2.c: In function 'mvpp2_cls_init':
> drivers/net/ethernet/marvell/mvpp2.c:3296:2: error: 'memset' used with length equal to number of elements without multiplication by element size [-Werror=memset-elt-size]
> 
> The result seems to be that we write uninitialized data into the
> flow table registers, although we did not get any warning about
> that uninitialized data usage.
> 
> Using sizeof() lets us initialize then entire array instead.
> 
> Fixes: 3f518509dedc ("ethernet: Add new driver for Marvell Armada 375 network unit")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied, thanks.
