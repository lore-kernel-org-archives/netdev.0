From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fix data delivery rate
Date: Sat, 16 Sep 2017 09:07:29 -0700 (PDT)
Message-ID: <20170916.090729.108058689813174554.davem@davemloft.net>
References: <20170915.143706.992734259378949259.davem@davemloft.net>
        <1505517411.29839.1.camel@edumazet-glaptop3.roam.corp.google.com>
        <1505519262.29839.5.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: liujian56@huawei.com, edumazet@google.com, ycheng@google.com,
        hkchu@google.com, netdev@vger.kernel.org, weiyongjun1@huawei.com,
        wangkefeng.wang@huawei.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51388 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751231AbdIPQHa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 16 Sep 2017 12:07:30 -0400
In-Reply-To: <1505519262.29839.5.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 15 Sep 2017 16:47:42 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Now skb->mstamp_skb is updated later, we also need to call
> tcp_rate_skb_sent() after the update is done.
> 
> Fixes: 8c72c65b426b ("tcp: update skb->skb_mstamp more carefully")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
