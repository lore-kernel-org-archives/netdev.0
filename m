From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 00/14] Swap-over-NBD without deadlocking v5
Date: Fri, 15 Jul 2011 11:27:38 -0400
Message-ID: <20110715152738.GA2276@infradead.org>
References: <1308575540-25219-1-git-send-email-mgorman@suse.de>
 <20110706165146.be7ab61b.akpm@linux-foundation.org>
 <20110707094737.GG15285@suse.de>
 <20110707125831.GA15412@infradead.org>
 <20110715141021.GZ7529@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux-MM <linux-mm@kvack.org>,
	Linux-Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Mel Gorman <mgorman@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110715141021.GZ7529@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 15, 2011 at 03:10:21PM +0100, Mel Gorman wrote:
> Any objection to the swap-over-NBD stuff going ahead to get part of the
> complexity out of the way?

Sure, that's what I was advocating for.  The filesystem interfaces in
the current swap over nbd patches on the other hand are complete crap
and need to be redone, but we've already discussed that a lot of times.
