From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] rps: flow_dissector: Fix uninitialized
 flow_keys used in __skb_get_hash possibly
Date: Thu, 01 Sep 2016 22:45:23 -0700 (PDT)
Message-ID: <20160901.224523.434756920053712480.davem@davemloft.net>
References: <1472624105-5163-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, aduyck@mirantis.com, amir@vadai.me,
        edumazet@google.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472624105-5163-1-git-send-email-fgao@ikuai8.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: fgao@ikuai8.com
Date: Wed, 31 Aug 2016 14:15:05 +0800

> From: Gao Feng <fgao@ikuai8.com>
> 
> The original codes depend on that the function parameters are evaluated from
> left to right. But the parameter's evaluation order is not defined in C
> standard actually.
> 
> When flow_keys_have_l4(&keys) is invoked before ___skb_get_hash(skb, &keys,
> hashrnd) with some compilers or environment, the keys passed to
> flow_keys_have_l4 is not initialized.
> 
> Fixes: 6db61d79c1e1 ("flow_dissector: Ignore flow dissector return value from ___skb_get_hash")
> 
> Acked-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Gao Feng <fgao@ikuai8.com>

Applied.
