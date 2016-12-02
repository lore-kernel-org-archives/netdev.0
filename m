From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/2] tcp: randomize tcp timestamp offsets
 for each connection
Date: Fri, 02 Dec 2016 12:50:13 -0500 (EST)
Message-ID: <20161202.125013.291984063589055137.davem@davemloft.net>
References: <1480588327-2902-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37476 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755215AbcLBRuS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 12:50:18 -0500
In-Reply-To: <1480588327-2902-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Thu,  1 Dec 2016 11:32:06 +0100

> jiffies based timestamps allow for easy inference of number of devices
> behind NAT translators and also makes tracking of hosts simpler.
> 
> commit ceaa1fef65a7c2e ("tcp: adding a per-socket timestamp offset")
> added the main infrastructure that is needed for per-connection ts
> randomization, in particular writing/reading the on-wire tcp header
> format takes the offset into account so rest of stack can use normal
> tcp_time_stamp (jiffies).
> 
> So only two items are left:
>  - add a tsoffset for request sockets
>  - extend the tcp isn generator to also return another 32bit number
>    in addition to the ISN.
> 
> Re-use of ISN generator also means timestamps are still monotonically
> increasing for same connection quadruple, i.e. PAWS will still work.
> 
> Includes fixes from Eric Dumazet.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>
> Acked-by: Eric Dumazet <edumazet@google.com>
> Acked-by: Yuchung Cheng <ycheng@google.com>

Applied.
