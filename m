From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] xen-netfront: be more drop monitor friendly
Date: Wed, 30 Aug 2017 16:01:38 -0700 (PDT)
Message-ID: <20170830.160138.764400239392146934.davem@davemloft.net>
References: <1504114378.11498.124.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36276 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751359AbdH3XBj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 19:01:39 -0400
In-Reply-To: <1504114378.11498.124.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 30 Aug 2017 10:32:58 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> xennet_start_xmit() might copy skb with inappropriate layout
> into a fresh one.
> 
> Old skb is freed, and at this point it is not a drop, but
> a consume. New skb will then be either consumed or dropped. 
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
