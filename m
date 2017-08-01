From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] net: Infrastructure changes for [kz]proxy
Date: Tue, 01 Aug 2017 15:26:34 -0700 (PDT)
Message-ID: <20170801.152634.1237241528233556282.davem@davemloft.net>
References: <20170728232243.3040-1-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rohit@quantonium.net,
        john.fastabend@gmail.com
To: tom@quantonium.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39170 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752334AbdHAW0f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 18:26:35 -0400
In-Reply-To: <20170728232243.3040-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@quantonium.net>
Date: Fri, 28 Jul 2017 16:22:40 -0700

> This patch set contains some general infrastructure enhancements that
> will be used by kernel proxy and zero proxy.
> 
> The changes are:
>   - proto_ops: Add locked versions of sendmsg and sendpage
>   - skb_send_sock: Allow sending and skb on a socket within the
>     kernel
>   - Generalize strparser. Allow it to be used in other contexts than
>     just in the read_sock path. This will be used in the transmit
>     path of zero proxy.
> 
> Some nice future work (which I've been discussing with John Fastabend)
> will be to make some of the related functions to allow gifting of skbs
> We should be able to do that with skb_send_sock and strp_process. I'd
> also like this feature in the read_sock callbeck.
> 
> Tested: Ran modified kernel without incident. Tested new functionality
> using zero proxy (in development).

Series applied, thanks Tom.
