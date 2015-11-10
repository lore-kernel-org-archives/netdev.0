From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH nf 1/2] net: add __netdev_alloc_pcpu_stats() to
 indicate gfp flags
Date: Tue, 10 Nov 2015 15:12:46 -0500 (EST)
Message-ID: <20151110.151246.88783320600707924.davem@davemloft.net>
References: <1447173390-2993-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, kaber@trash.net,
	netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1447173390-2993-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Tue, 10 Nov 2015 17:36:28 +0100

> nf_tables may create percpu counters from the packet path through its
> dynamic set instantiation infrastructure, so we need a way to allocate
> this through GFP_ATOMIC.
> 
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Acked-by: David S. Miller <davem@davemloft.net>
