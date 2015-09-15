From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 25/39] net: core: drop null test before destroy
 functions
Date: Tue, 15 Sep 2015 16:50:03 -0700 (PDT)
Message-ID: <20150915.165003.84354714289428204.davem@davemloft.net>
References: <1442146532-9100-1-git-send-email-Julia.Lawall@lip6.fr>
	<1442146532-9100-26-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergey.senozhatsky@gmail.com, kernel-janitors@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1442146532-9100-26-git-send-email-Julia.Lawall@lip6.fr>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Sun, 13 Sep 2015 14:15:18 +0200

> Remove unneeded NULL test.
> 
> The semantic patch that makes this change is as follows:
> (http://coccinelle.lip6.fr/)
> 
> // <smpl>
> @@ expression x; @@
> -if (x != NULL) {
>   \(kmem_cache_destroy\|mempool_destroy\|dma_pool_destroy\)(x);
>   x = NULL;
> -}
> // </smpl>
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied.
