From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the final tree (net
 tree related)
Date: Wed, 02 Nov 2011 01:50:04 -0400 (EDT)
Message-ID: <20111102.015004.118482982480965571.davem@davemloft.net>
References: <20111102163708.75d719e765dea20e0c4c5a04@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111102163708.75d719e765dea20e0c4c5a04@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 2 Nov 2011 16:37:08 +1100

> Subject: [PATCH] net: fix typo in drivers/net/ethernet/xilinx/ll_temac_main.c
> 
> Commit 9e903e085262 ("net: add skb frag size accessors") used frag_size
> instead of skb_frag_size in this file.
> 
> Fixes this build error:
> 
> drivers/net/ethernet/xilinx/ll_temac_main.c: In function 'temac_start_xmit':
> drivers/net/ethernet/xilinx/ll_temac_main.c:717:3: error: implicit declaration of function 'frag_size' [-Werror=implicit-function-declaration]
> 
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

Applied, thanks!
