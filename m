From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: ax88796: avoid 64 bit arithmetic
Date: Fri, 19 Apr 2013 17:58:10 -0400 (EDT)
Message-ID: <20130419.175810.1381475568379872070.davem@davemloft.net>
References: <201304191506.21220.arnd@arndb.de>
	<20130419.133603.1487086024178553164.davem@davemloft.net>
	<201304192047.26720.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ben@fluff.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48854 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933335Ab3DSV6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 17:58:12 -0400
In-Reply-To: <201304192047.26720.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 19 Apr 2013 20:47:26 +0200

> When building ax88796 on an ARM platform with 64-bit resource_size_t,
> we currently get
> 
> drivers/net/ethernet/8390/ax88796.c:875: undefined reference to `__aeabi_uldivmod'
> 
> because we do a division on the length of the MMIO resource.
> Since we know that this resource is very short, using an
> "unsigned long" instead of "resource_size_t" is entirely
> sufficient, and avoids this link-time error.
> 
> Cc: Ben Dooks <ben-linux@fluff.org>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
