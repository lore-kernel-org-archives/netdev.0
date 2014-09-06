From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: remove obsolete comment about
 TCP_SKB_CB(skb)->when in tcp_fragment()
Date: Sat, 06 Sep 2014 08:30:36 -0700
Message-ID: <1410017436.11872.32.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1410016700-9145-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, edumazet@google.com,
	ycheng@google.com, netdev@vger.kernel.org
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:52910 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751354AbaIFPai (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Sep 2014 11:30:38 -0400
Received: by mail-pa0-f42.google.com with SMTP id lf10so24247555pab.29
        for <netdev@vger.kernel.org>; Sat, 06 Sep 2014 08:30:38 -0700 (PDT)
In-Reply-To: <1410016700-9145-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-09-06 at 11:18 -0400, Neal Cardwell wrote:
> The TCP_SKB_CB(skb)->when field no longer exists as of recent change
> 7faee5c0d514 ("tcp: remove TCP_SKB_CB(skb)->when"). And in any case,
> tcp_fragment() is called on already-transmitted packets from the
> __tcp_retransmit_skb() call site, so copying timestamps of any kind
> in this spot is quite sensible.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Reported-by: Yuchung Cheng <ycheng@google.com>
> ---
>  net/ipv4/tcp_output.c | 3 ---

Acked-by: Eric Dumazet <edumazet@google.com>
