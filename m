From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: neigh: guard against NULL solicit() method
Date: Thu, 23 Mar 2017 21:28:49 -0700 (PDT)
Message-ID: <20170323.212849.796880770292613157.davem@davemloft.net>
References: <1490284858.16816.205.camel@edumazet-glaptop3.roam.corp.google.com>
        <20170323.120035.1924712018254677829.davem@davemloft.net>
        <1490297961.9687.6.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, dvyukov@google.com, xiyou.wangcong@gmail.com,
        herbert@gondor.apana.org.au, ast@kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        syzkaller@googlegroups.com
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1490297961.9687.6.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 23 Mar 2017 12:39:21 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Dmitry posted a nice reproducer of a bug triggering in neigh_probe()
> when dereferencing a NULL neigh->ops->solicit method.
> 
> This can happen for arp_direct_ops/ndisc_direct_ops and similar,
> which can be used for NUD_NOARP neighbours (created when dev->header_ops
> is NULL). Admin can then force changing nud_state to some other state
> that would fire neigh timer.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>

Applied and queued up for -stable, thanks Eric.
