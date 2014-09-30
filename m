From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netfilter: bridge: build br_nf_core only if
 required
Date: Tue, 30 Sep 2014 14:10:01 -0400 (EDT)
Message-ID: <20140930.141001.265442216668830904.davem@davemloft.net>
References: <1412067559-28733-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, therbert@google.com, fw@strlen.de
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1412067559-28733-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Tue, 30 Sep 2014 10:59:18 +0200

> From: Florian Westphal <fw@strlen.de>
> 
> Eric reports build failure with
> CONFIG_BRIDGE_NETFILTER=n
> 
> We insist to build br_nf_core.o unconditionally, but we must only do so
> if br_netfilter was enabled, else it fails to build due to
> functions being defined to empty stubs (and some structure members
> being defined out).
> 
> Also, BRIDGE_NETFILTER=y|m makes no sense when BRIDGE=n.
> 
> Fixes: 34666d467 (netfilter: bridge: move br_netfilter out of the core)
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Applied, thanks.
