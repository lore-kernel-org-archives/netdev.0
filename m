From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drop_monitor: allow more events per second
Date: Sat, 21 Apr 2012 16:29:09 -0400 (EDT)
Message-ID: <20120421.162909.813928373556454918.davem@davemloft.net>
References: <1334855781.2395.203.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43716 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750911Ab2DUUaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Apr 2012 16:30:19 -0400
In-Reply-To: <1334855781.2395.203.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 19 Apr 2012 19:16:21 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> It seems there is a logic error in trace_drop_common(), since we store
> only 64 drops, even if they are from same location.
> 
> This fix is a one liner, but we probably need more work to avoid useless
> atomic dec/inc
> 
> Now I can watch 1 Mpps drops through dropwatch...
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Neil Horman <nhorman@tuxdriver.com>

Applied, thanks.
