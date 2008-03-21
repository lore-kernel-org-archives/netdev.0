From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3 resend] TCP_DEFER_ACCEPT updates - dont retxmt
 synack
Date: Fri, 21 Mar 2008 16:29:50 -0700 (PDT)
Message-ID: <20080321.162950.78130414.davem@davemloft.net>
References: <1206053493.13044.14.camel@tng>
	<1206053755.13044.22.camel@tng>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mcmanus@ducksong.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39217
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750816AbYCUX3d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2008 19:29:33 -0400
In-Reply-To: <1206053755.13044.22.camel@tng>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McManus <mcmanus@ducksong.com>
Date: Thu, 20 Mar 2008 18:55:55 -0400

> commit 95dea62ad7004a1de84e1f38c1b5243e1cb0d554
> Author: Patrick McManus <mcmanus@ducksong.com>
> Date:   Sat Feb 23 15:59:22 2008 -0500
> 
>     a socket in LISTEN that had completed its 3 way handshake, but not notified
>     userspace because of SO_DEFER_ACCEPT, would retransmit the already
>     acked syn-ack during the time it was waiting for the first data byte
>     from the peer.
>     
>     Signed-off-by: Patrick McManus <mcmanus@ducksong.com>
>     Acked-by: Eric Dumazet <dada1@cosmosbay.com>

Applied to net-2.6.26
