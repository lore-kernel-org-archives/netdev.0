From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] net: define accessors to get/set skb->dst and
 skb->rtable
Date: Wed, 03 Jun 2009 03:35:21 -0700 (PDT)
Message-ID: <20090603.033521.215812392.davem@davemloft.net>
References: <4A25414D.6040605@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44017
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752881AbZFCKfV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 06:35:21 -0400
In-Reply-To: <4A25414D.6040605@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 02 Jun 2009 17:12:13 +0200

> Here are patches I originally cooked to review all places that could need skb->dst
> 
> I believe they could be applied in net-next-2.6 because we could then
> implement what we discussed in last december, about avoiding
> refcounting on dst_entries in input path (thread about IP_PKTINFO stuff,
> and a patch we had to revert)
> 
> You suggested to use the low order bit of skb->dst to tell if we got a
> refcount or not.
> 
> These four patches implement grounding for this idea (no functional changes yet)
> 
> Next step is adding the low order bit handling (or another bit if it happens
> to be too expensive to check this bit each time we want skb->dst, we
> still have to benchmark this)

It all looks great, applied, thanks Eric!
