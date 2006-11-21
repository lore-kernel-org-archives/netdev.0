From: David Miller <davem@davemloft.net>
Subject: Re: [-mm patch] make net/core/skbuff.c:skb_over_panic() static
Date: Mon, 20 Nov 2006 17:39:16 -0800 (PST)
Message-ID: <20061120.173916.21925337.davem@davemloft.net>
References: <20061114014125.dd315fff.akpm@osdl.org>
	<20061117170205.GE31879@stusta.de>
	<20061120.195556.23029046.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33705
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030633AbWKUBjM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Nov 2006 20:39:12 -0500
To: bunk@stusta.de
In-Reply-To: <20061120.195556.23029046.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Mon, 20 Nov 2006 19:55:56 -0500 (EST)

> From: Adrian Bunk <bunk@stusta.de>
> Date: Fri, 17 Nov 2006 18:02:05 +0100
> 
> > skb_over_panic() can now become static.
> > 
> > Signed-off-by: Adrian Bunk <bunk@stusta.de>
> 
> Applied to net-2.6.20, thanks Adrian.

I just realized this requires a patch already in -mm which
isn't in my tree.

Sorry about that.

I really doubt I'll put that skb_put() patch into my tree,
ever, we can just remove the debugging checks or make them
conditional to keep the inline.
