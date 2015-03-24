From: David Miller <davem@davemloft.net>
Subject: Re: rhashtable: warnings caused by "rhashtable: Fix use-after-free
 in rhashtable_walk_stop"
Date: Mon, 23 Mar 2015 22:16:24 -0400 (EDT)
Message-ID: <20150323.221624.2222527689667678224.davem@davemloft.net>
References: <55105B2E.1070409@oracle.com>
	<20150323215513.GA20128@gondor.apana.org.au>
	<20150323225317.GA20707@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sasha.levin@oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tgraf@suug.ch
To: herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150323225317.GA20707@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 24 Mar 2015 09:53:17 +1100

> rhashtable: Fix sleeping inside RCU critical section in walk_stop
> 
> The commit 963ecbd41a1026d99ec7537c050867428c397b89 ("rhashtable:
> Fix use-after-free in rhashtable_walk_stop") fixed a real bug
> but created another one because we may end up sleeping inside an
> RCU critical section.
> 
> This patch fixes it properly by replacing the mutex with a spin
> lock that specifically protects the walker lists.
> 
> Reported-by: Sasha Levin <sasha.levin@oracle.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks everyone.
