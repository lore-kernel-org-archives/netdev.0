From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET] fix useless comment reference loop
Date: Sat, 03 May 2008 20:57:32 -0700 (PDT)
Message-ID: <20080503.205732.48777773.davem@davemloft.net>
References: <1209852342.3673.16.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47641
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751403AbYEDD5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 May 2008 23:57:32 -0400
In-Reply-To: <1209852342.3673.16.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Sun, 04 May 2008 00:05:42 +0200

> include/linux/skbuff.h says:
>         /* These elements must be at the end, see alloc_skb() for details.  */
> 
> net/core/skbuff.c says:
> 	* See comment in sk_buff definition, just before the 'tail' member
> 
> This patch contains my guess as to the actual reason rather than a
> dead comment reference loop.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

Patch applied, thanks.

This is an example of why I'm personally a comment minimalist.
They tend to rot, confuse people, and often just duplicate what
is obvious from the code (although not in this case).
