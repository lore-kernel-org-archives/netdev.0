From: David Miller <davem@davemloft.net>
Subject: Re: Crash due to mutex genl_lock called from RCU context
Date: Tue, 29 Nov 2016 19:49:00 -0500 (EST)
Message-ID: <20161129.194900.805119822120840845.davem@davemloft.net>
References: <1480263824.18162.44.camel@edumazet-glaptop3.roam.corp.google.com>
        <CAM_iQpXB_LRqE83cWwU0ZDckLWPrMcZg-yD4+NKy+rBVz3YAyw@mail.gmail.com>
        <20161128112211.GA990@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        subashab@codeaurora.org, tgraf@suug.ch, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38160 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752167AbcK3AtC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 19:49:02 -0500
In-Reply-To: <20161128112211.GA990@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 28 Nov 2016 19:22:12 +0800

> netlink: Call cb->done from a worker thread
> 
> The cb->done interface expects to be called in process context.
> This was broken by the netlink RCU conversion.  This patch fixes
> it by adding a worker struct to make the cb->done call where
> necessary.
> 
> Fixes: 21e4902aea80 ("netlink: Lockless lookup with RCU grace...")
> Reported-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied and queued up for -stable, thanks Herbert.
