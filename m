From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] net: bcmgenet: fix dma api length mismatch
Date: Thu, 17 Mar 2016 16:16:48 -0700
Message-ID: <56EB3AE0.5030604@gmail.com>
References: <1458137881.7353.9.camel@edumazet-glaptop3.roam.corp.google.com>
 <56EAE2A8.5000206@gmail.com>
 <1458241026.7353.62.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, opendmb@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35458 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031459AbcCQXS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 19:18:28 -0400
Received: by mail-pf0-f170.google.com with SMTP id n5so140079883pfn.2
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2016 16:18:27 -0700 (PDT)
In-Reply-To: <1458241026.7353.62.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/03/16 11:57, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> When un-mapping skb->data in __bcmgenet_tx_reclaim(),
> we must use the length that was used in original dma_map_single(),
> instead of skb->len that might be bigger (includes the frags)
> 
> We simply can store skb_len into tx_cb_ptr->dma_len and use it
> at unmap time.
> 
> Fixes: 1c1008c793fa ("net: bcmgenet: add main driver file")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

Good catch, thanks!
-- 
Florian
