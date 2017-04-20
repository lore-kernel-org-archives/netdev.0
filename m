From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: Heads-up: two regressions in v4.11-rc series
Date: Thu, 20 Apr 2017 15:30:33 +0100
Message-ID: <20170420143033.3nzi6nruqd5s3n7f@techsingularity.net>
References: <20170420110042.73d01e0f@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	peterz@infradead.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20170420110042.73d01e0f@redhat.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 20, 2017 at 11:00:42AM +0200, Jesper Dangaard Brouer wrote:
> Hi Linus,
> 
> Just wanted to give a heads-up on two regressions in 4.11-rc series.
> 
> (1) page allocator optimization revert
> 
> Mel Gorman and I have been playing with optimizing the page allocator,
> but Tariq spotted that we caused a regression for (NIC) drivers that
> refill DMA RX rings in softirq context.
> 
> The end result was a revert, and this is waiting in AKPMs quilt queue:
>  http://ozlabs.org/~akpm/mmots/broken-out/revert-mm-page_alloc-only-use-per-cpu-allocator-for-irq-safe-requests.patch
> 

This was flagged to Andrew that it should go in for either 4.11 or if
there were concerns about how close to the release we are then put it in
for 4.11-stable. At worst, I can do a resubmit to -stable myself after
it gets merged in the next window if it falls between the cracks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
