From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] net: prevent setting ttl=0 via IP_TTL
Date: Tue, 08 Jan 2013 17:57:55 -0800 (PST)
Message-ID: <20130108.175755.500141755302198039.davem@davemloft.net>
References: <1357629420-29725-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, padalia.nitin@gmail.com,
	eric.dumazet@gmail.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36088 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753851Ab3AIB5z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 20:57:55 -0500
In-Reply-To: <1357629420-29725-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue,  8 Jan 2013 15:17:00 +0800

> From: Cong Wang <xiyou.wangcong@gmail.com>
> 
> A regression is introduced by the following commit:
> 
> 	commit 4d52cfbef6266092d535237ba5a4b981458ab171
> 	Author: Eric Dumazet <eric.dumazet@gmail.com>
> 	Date:   Tue Jun 2 00:42:16 2009 -0700
> 
> 	    net: ipv4/ip_sockglue.c cleanups
> 	    
> 	    Pure cleanups
> 
> but it is not a pure cleanup...
> 
> 	-               if (val != -1 && (val < 1 || val>255))
> 	+               if (val != -1 && (val < 0 || val > 255))
> 
> Since there is no reason provided to allow ttl=0, change it back.
> 
> Reported-by: nitin padalia <padalia.nitin@gmail.com>
> Cc: nitin padalia <padalia.nitin@gmail.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied and queued up for -stable, thanks.
