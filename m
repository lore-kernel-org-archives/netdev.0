From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Subject: Re: [PATCH net] tcp: fix data delivery rate
Date: Fri, 15 Sep 2017 21:33:03 -0400
Message-ID: <CADAM+B1mx1YratvGDNXHqkFsV=7g=4K5emmX4pJX8c8VQJxNtg@mail.gmail.com>
References: <3c750ac3-8739-89ed-ce41-d4cde755171e@huawei.com>
 <1505313647.15310.165.camel@edumazet-glaptop3.roam.corp.google.com>
 <1505359839.15310.209.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170915.143706.992734259378949259.davem@davemloft.net> <1505517411.29839.1.camel@edumazet-glaptop3.roam.corp.google.com>
 <1505519262.29839.5.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>, liujian <liujian56@huawei.com>,
        Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Jerry Chu <hkchu@google.com>, netdev <netdev@vger.kernel.org>,
        "weiyongjun (A)" <weiyongjun1@huawei.com>,
        wangkefeng 00227729 <wangkefeng.wang@huawei.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f48.google.com ([209.85.213.48]:46956 "EHLO
        mail-vk0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751117AbdIPBdo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2017 21:33:44 -0400
Received: by mail-vk0-f48.google.com with SMTP id v203so1745361vkv.3
        for <netdev@vger.kernel.org>; Fri, 15 Sep 2017 18:33:44 -0700 (PDT)
In-Reply-To: <1505519262.29839.5.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 15, 2017 at 7:47 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Now skb->mstamp_skb is updated later, we also need to call
> tcp_rate_skb_sent() after the update is done.
>
> Fixes: 8c72c65b426b ("tcp: update skb->skb_mstamp more carefully")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Soheil Hassas Yeganeh <soheil@google.com>

Nice catch!
