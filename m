From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] neigh: reorder struct neighbour
Date: Thu, 11 Nov 2010 10:41:38 -0800 (PST)
Message-ID: <20101111.104138.59661151.davem@davemloft.net>
References: <1289494639.17691.1499.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50591
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752747Ab0KKSlN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 13:41:13 -0500
In-Reply-To: <1289494639.17691.1499.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 11 Nov 2010 17:57:19 +0100

> It is important to move nud_state outside of the often modified cache
> line (because of refcnt), to reduce false sharing in neigh_event_send()
> 
> This is a followup of commit 0ed8ddf4045f (neigh: Protect neigh->ha[]
> with a seqlock)
> 
> This gives a 7% speedup on routing test with IP route cache disabled.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> David, it appears I forgot to push this patch, I have it in my tree
> since one month. Thanks !

Applied, thanks.
