From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 3/5] net: ep93xx_eth: allocate buffers using
 kmalloc()
Date: Sat, 11 Jun 2011 16:25:40 -0700 (PDT)
Message-ID: <20110611.162540.868268573517714775.davem@davemloft.net>
References: <a908e30a30247a07b2352002742f291d1df0eb18.1307816881.git.mika.westerberg@iki.fi>
	<a908e30a30247a07b2352002742f291d1df0eb18.1307816881.git.mika.westerberg@iki.fi>
	<511e0ae99e245fccb4692e7bb51944575f1b3287.1307816881.git.mika.westerberg@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	hsweeten@visionengravers.com, rmallon@gmail.com, ynezz@true.cz
To: mika.westerberg@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38037 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752907Ab1FKX0v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2011 19:26:51 -0400
In-Reply-To: <511e0ae99e245fccb4692e7bb51944575f1b3287.1307816881.git.mika.westerberg@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mika Westerberg <mika.westerberg@iki.fi>
Date: Sat, 11 Jun 2011 21:39:56 +0300

> We can use simply kmalloc() to allocate the buffers. This also simplifies the
> code and allows us to perform DMA sync operations more easily.
> 
> Memory is allocated with only GFP_KERNEL since there are no DMA allocation
> restrictions on this platform.
> 
> Signed-off-by: Mika Westerberg <mika.westerberg@iki.fi>
> Acked-by: Russell King <rmk+kernel@arm.linux.org.uk>
> Acked-by: H Hartley Sweeten <hsweeten@visionengravers.com>
> Tested-by: Petr Stetiar <ynezz@true.cz>

Applied.
