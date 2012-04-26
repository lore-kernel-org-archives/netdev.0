From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp repair: Fix unaligned access when repairing
 options (v2)
Date: Thu, 26 Apr 2012 05:23:36 -0400 (EDT)
Message-ID: <20120426.052336.664675835426476301.davem@davemloft.net>
References: <4F990C71.3020500@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David.Laight@ACULAB.COM
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58227 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753559Ab2DZJXx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 05:23:53 -0400
In-Reply-To: <4F990C71.3020500@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Thu, 26 Apr 2012 12:50:57 +0400

> Don't pick __u8/__u16 values directly from raw pointers, but instead use
> an array of structures of code:value pairs. This is OK, since the buffer
> we take options from is not an skb memory, but a user-to-kernel one.
> 
> For those options which don't require any value now, require this to be
> zero (for potential future extension of this API).
> 
> v2: Changed tcp_repair_opt to use two __u32-s as spotted by David Laight.
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

Hmmm, this didn't show up on netdev, I wonder why?
