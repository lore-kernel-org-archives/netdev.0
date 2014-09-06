From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: remove obsolete comment about
 TCP_SKB_CB(skb)->when in tcp_fragment()
Date: Sat, 06 Sep 2014 12:29:31 -0700 (PDT)
Message-ID: <20140906.122931.153026708934046806.davem@davemloft.net>
References: <1410016700-9145-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, ycheng@google.com, netdev@vger.kernel.org
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40501 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751354AbaIFT3u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Sep 2014 15:29:50 -0400
In-Reply-To: <1410016700-9145-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Sat,  6 Sep 2014 11:18:20 -0400

> The TCP_SKB_CB(skb)->when field no longer exists as of recent change
> 7faee5c0d514 ("tcp: remove TCP_SKB_CB(skb)->when"). And in any case,
> tcp_fragment() is called on already-transmitted packets from the
> __tcp_retransmit_skb() call site, so copying timestamps of any kind
> in this spot is quite sensible.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Reported-by: Yuchung Cheng <ycheng@google.com>

Applied, thanks Neal.
