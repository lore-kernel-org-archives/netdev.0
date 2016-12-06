From: David Miller <davem@davemloft.net>
Subject: Re: [v3 PATCH] netlink: Do not schedule work from sk_destruct
Date: Mon, 05 Dec 2016 19:44:14 -0500 (EST)
Message-ID: <20161205.194414.1922270027505338684.davem@davemloft.net>
References: <20161205071946.GB9496@gondor.apana.org.au>
        <20161205072600.GA10204@gondor.apana.org.au>
        <20161205072820.GB10204@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, andreyknvl@google.com,
        johannes.berg@intel.com, fw@strlen.de, edumazet@google.com,
        me@bobcopeland.com, tom@herbertland.com, decot@googlers.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161205072820.GB10204@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 5 Dec 2016 15:28:21 +0800

> It is wrong to schedule a work from sk_destruct using the socket
> as the memory reserve because the socket will be freed immediately
> after the return from sk_destruct.
> 
> Instead we should do the deferral prior to sk_free.
> 
> This patch does just that.
> 
> Fixes: 707693c8a498 ("netlink: Call cb->done from a worker thread")
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
