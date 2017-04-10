From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: Page allocator order-0 optimizations merged
Date: Mon, 10 Apr 2017 16:10:51 +0100
Message-ID: <20170410151051.n4lytmha4tqh4l3t@techsingularity.net>
References: <58b48b1f.F/jo2/WiSxvvGm/z%akpm@linux-foundation.org>
 <20170301144845.783f8cad@redhat.com>
 <58EB9754.3090202@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	akpm@linux-foundation.org, linux-mm <linux-mm@kvack.org>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>
To: zhong jiang <zhongjiang@huawei.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <58EB9754.3090202@huawei.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 10, 2017 at 10:31:48PM +0800, zhong jiang wrote:
> Hi, Mel
> 
>      The patch I had test on arm64. I find the great degradation. I test it by micro-bench.
>     The patrly data is as following.  and it is stable.  That stands for the allocate and free time. 
>     

What type of allocations is the benchmark doing? In particular, what context
is the microbenchmark allocating from? Lastly, how did you isolate the
patch, did you test two specific commits in mainline or are you comparing
4.10 with 4.11-rcX?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
