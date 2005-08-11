From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2/2] fix NF_QUEUE_NR() macro
Date: Thu, 11 Aug 2005 15:43:11 -0700 (PDT)
Message-ID: <20050811.154311.71554197.davem@davemloft.net>
References: <200508111631.24785.netdev@axxeo.de>
	<E1E3Kt5-0006jy-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	netdev@axxeo.de, laforge@gnumonks.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: herbert@gondor.apana.org.au
In-Reply-To: <E1E3Kt5-0006jy-00@gondolin.me.apana.org.au>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 12 Aug 2005 07:46:55 +1000

> Actually, these two versions are different.  & is higher than | so
> Harald's version is actually 
> 
> #define NF_QUEUE_NR(x) (((x << NF_VERDICT_QBITS) & NF_VERDICT_QMASK) | NF_QUEUE)
> 
> Which is it?

It's the former that is the intended version.

I put Harald's patch in as-is, if people want to pretty it
up please do so with a follow-on patch but I really don't
think it matters :-)
