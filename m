From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bna: fix skb->truesize underestimation
Date: Fri, 17 Oct 2014 23:56:58 -0400 (EDT)
Message-ID: <20141017.235658.809511246236814038.davem@davemloft.net>
References: <1413575155.27176.5.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rasesh.mody@qlogic.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44400 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751569AbaJRD5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 23:57:00 -0400
In-Reply-To: <1413575155.27176.5.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 17 Oct 2014 12:45:55 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> skb->truesize is not meant to be tracking amount of used bytes
> in an skb, but amount of reserved/consumed bytes in memory.
> 
> For instance, if we use a single byte in last page fragment,
> we have to account the full size of the fragment.
> 
> skb->truesize can be very different from skb->len, that has
> a very specific safety purpose.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
