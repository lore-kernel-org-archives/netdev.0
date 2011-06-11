From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 2/5] net: ep93xx_eth: pass struct device to DMA API
 functions
Date: Sat, 11 Jun 2011 16:25:33 -0700 (PDT)
Message-ID: <20110611.162533.1598577745882301197.davem@davemloft.net>
References: <a908e30a30247a07b2352002742f291d1df0eb18.1307816881.git.mika.westerberg@iki.fi>
	<a908e30a30247a07b2352002742f291d1df0eb18.1307816881.git.mika.westerberg@iki.fi>
	<b69ec17080017f62baaa94bc1d21960022dc7381.1307816881.git.mika.westerberg@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	hsweeten@visionengravers.com, rmallon@gmail.com, ynezz@true.cz
To: mika.westerberg@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38026 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752211Ab1FKX0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2011 19:26:44 -0400
In-Reply-To: <b69ec17080017f62baaa94bc1d21960022dc7381.1307816881.git.mika.westerberg@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mika Westerberg <mika.westerberg@iki.fi>
Date: Sat, 11 Jun 2011 21:39:55 +0300

> We shouldn't use NULL for any DMA API functions, unless we are dealing with
> ISA or EISA device. So pass correct struct dev pointer to these functions.
> 
> Signed-off-by: Mika Westerberg <mika.westerberg@iki.fi>

Applied.
