From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] netfilter: Correct calculation using
 skb->tail and skb-network_header
Date: Fri, 31 May 2013 16:38:50 -0700 (PDT)
Message-ID: <20130531.163850.493455196018855311.davem@davemloft.net>
References: <1369967969-32375-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, gang.chen@asianux.com
To: horms@verge.net.au
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1369967969-32375-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Horman <horms@verge.net.au>
Date: Fri, 31 May 2013 11:39:29 +0900

> This corrects an regression introduced by "net: Use 16bits for *_headers
> fields of struct skbuff" when NET_SKBUFF_DATA_USES_OFFSET is not set. In
> that case skb->tail will be a pointer whereas skb->network_header
> will be an offset from head. This is corrected by using wrappers that
> ensure that calculations are always made using pointers.
> 
> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
> Reported-by: Chen Gang <gang.chen@asianux.com>
> Signed-off-by: Simon Horman <horms@verge.net.au>

I've applied this directly to net-next, thanks Simon.
