From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: ipv6: initialize treq->txhash in
 cookie_v[46]_check()
Date: Mon, 17 Jul 2017 10:42:59 -0700
Message-ID: <1500313379.5566.21.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170717103558.35448-1-glider@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, kcc@google.com, edumazet@google.com,
        davem@davemloft.net, netdev@vger.kernel.org
To: Alexander Potapenko <glider@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35609 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751293AbdGQRnD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 13:43:03 -0400
Received: by mail-wm0-f67.google.com with SMTP id u23so304536wma.2
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 10:43:02 -0700 (PDT)
In-Reply-To: <20170717103558.35448-1-glider@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-07-17 at 12:35 +0200, Alexander Potapenko wrote:
> KMSAN reported use of uninitialized memory in skb_set_hash_from_sk(),
> which originated from the TCP request socket created in
> cookie_v6_check():

> Similar error is reported for cookie_v4_check().
> 
> Signed-off-by: Alexander Potapenko <glider@google.com>
> Fixes: 58d607d3e52f ("tcp: provide skb->hash to synack packets")

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
