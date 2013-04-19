From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ax88796: avoid 64 bit arithmetic
Date: Fri, 19 Apr 2013 13:36:03 -0400 (EDT)
Message-ID: <20130419.133603.1487086024178553164.davem@davemloft.net>
References: <201304191506.21220.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ben@fluff.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44172 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751368Ab3DSRgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 13:36:07 -0400
In-Reply-To: <201304191506.21220.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 19 Apr 2013 15:06:21 +0200

> When building ax88796 on an ARM platform with 64-bit resource_size_t,
> we currently get
> 
> drivers/net/ethernet/8390/ax88796.c:875: undefined reference to `__aeabi_uldivmod'
> 
> because we do a division on the length of the MMIO resource.
> Since we know that this resource is very short, using an
> "unsigned long" instead of "resource_size_t" is entirely
> sufficient, and avoids this link-time error.

Please provide a proper signoff with your patches, thanks.
