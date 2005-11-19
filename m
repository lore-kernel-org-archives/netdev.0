From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] [RFT] ip_tables NUMA optimization
Date: Fri, 18 Nov 2005 16:00:43 -0800 (PST)
Message-ID: <20051118.160043.119281166.davem@davemloft.net>
References: <20051117144328.GG14201@sunbeam.de.gnumonks.org>
	<437CA009.4020006@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: laforge@netfilter.org, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: dada1@cosmosbay.com
In-Reply-To: <437CA009.4020006@cosmosbay.com>
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

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 17 Nov 2005 16:21:45 +0100

> It should probably use vfree() like :
> 
>  > +	for_each_cpu(cpu) {
>  > +		if (info->size <= PAGE_SIZE)
>  > +			kfree(info->entries[cpu]);
>  > +		else
>  > +			vfree(info->entries[cpu]);
>  > +	}

I've put the patch into the net-2.6.16 tree with the obvious
fix Eric points out.

Thanks.
