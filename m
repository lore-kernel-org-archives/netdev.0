From: Eric Wong <normalperson@yhbt.net>
Subject: Re: ppoll() stuck on POLLIN while TCP peer is sending
Date: Fri, 11 Jan 2013 00:51:05 +0000
Message-ID: <20130111005105.GA15023@dcvr.yhbt.net>
References: <20130110194212.GJ13304@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mm@kvack.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>,
	Minchan Kim <minchan@kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Mel Gorman <mgorman@suse.de>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20130110194212.GJ13304@suse.de>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Mel Gorman <mgorman@suse.de> wrote:
> mm: compaction: Partially revert capture of suitable high-order page

<snip>
 
> Reported-by: Eric Wong <normalperson@yhbt.net>
> Cc: stable@vger.kernel.org
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Thanks, my original use case and test works great after several hours!

Tested-by: Eric Wong <normalperson@yhbt.net>


Unfortunately, I also hit a new bug in 3.8 (not in 3.7.x).  based on Eric
Dumazet's observations, sk_stream_wait_memory may be to blame.
Fortunately this is easier to reproduce (I've cc-ed participants
on this thread already): <20130111004915.GA15415@dcvr.yhbt.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
