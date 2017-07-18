From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: ipv6: initialize treq->txhash in
 cookie_v[46]_check()
Date: Tue, 18 Jul 2017 11:23:38 -0700 (PDT)
Message-ID: <20170718.112338.288656675048363598.davem@davemloft.net>
References: <20170717103558.35448-1-glider@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, kcc@google.com, edumazet@google.com,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: glider@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170717103558.35448-1-glider@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Potapenko <glider@google.com>
Date: Mon, 17 Jul 2017 12:35:58 +0200

> KMSAN reported use of uninitialized memory in skb_set_hash_from_sk(),
> which originated from the TCP request socket created in
> cookie_v6_check():
 ...
> Similar error is reported for cookie_v4_check().
> 
> Signed-off-by: Alexander Potapenko <glider@google.com>
> Fixes: 58d607d3e52f ("tcp: provide skb->hash to synack packets")

Applied and queued up for -stable, thanks!
