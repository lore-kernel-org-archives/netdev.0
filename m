From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Silence a W=1 compiler warning
Date: Fri, 13 Jun 2014 13:28:29 -0700 (PDT)
Message-ID: <20140613.132829.1371591602611461717.davem@davemloft.net>
References: <539B06E1.4050005@acm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, netdev@vger.kernel.org
To: bvanassche@acm.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60474 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751456AbaFMU2a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2014 16:28:30 -0400
In-Reply-To: <539B06E1.4050005@acm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bart Van Assche <bvanassche@acm.org>
Date: Fri, 13 Jun 2014 16:12:49 +0200

> Avoid that the following compiler warning is reported when building
> with W=1:
> 
> include/linux/netdevice.h: In function 'netif_addr_lock_nested':
> include/linux/netdevice.h:2865:6: warning: variable 'subclass' set but not used [-Wunused-but-set-variable]
>   int subclass = SINGLE_DEPTH_NESTING;
>       ^
> 
> This patch does not change any functionality.
> 
> Signed-off-by: Bart Van Assche <bvanassche@acm.org>

This has already been discussed.

The spin_lock_nested() with your configuration should be adjusted to
mark the argument as used.

There is nothing wrong with this code, it should not warn, it's
simply the spin locking macros that need to be fixed.

I'm not applying this patch, sorry.
