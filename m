From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pktgen: Fix multiqueue handling
Date: Sun, 04 Oct 2009 21:09:23 -0700 (PDT)
Message-ID: <20091004.210923.82587218.davem@davemloft.net>
References: <4AC6EE3B.6050407@gmail.com>
	<19143.42215.379289.481809@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, robert.olsson@its.uu.se,
	netdev@vger.kernel.org, shemminger@vyatta.com
To: robert@herjulf.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45058
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751164AbZJEEJ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 00:09:29 -0400
In-Reply-To: <19143.42215.379289.481809@gargle.gargle.HOWL>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Olsson <robert@herjulf.net>
Date: Sat, 3 Oct 2009 21:24:23 +0200

> 
> 
> Thanks yes is seems right. We can chose a single arbitrary TX queue with the patch.
> BTW Noticed you and Stephen discussed to reduce dirtying skb->users, maybe the idea
> to bump up skb->users to clone_skb is not so bad. I'll think the code will be pretty 
> straight-forward. 
> 
> Cheers
> 						--ro
> 
>  
> Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>

Applied, thanks everyone.
