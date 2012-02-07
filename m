From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 02/15] mm: sl[au]b: Add knowledge of PFMEMALLOC reserve
 pages
Date: Tue, 7 Feb 2012 10:27:56 -0600 (CST)
Message-ID: <alpine.DEB.2.00.1202071025050.30652@router.home>
References: <1328568978-17553-1-git-send-email-mgorman@suse.de> <1328568978-17553-3-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>,
  Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
  David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>,
  Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Mel Gorman <mgorman@suse.de>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1328568978-17553-3-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, 6 Feb 2012, Mel Gorman wrote:

> Pages allocated from the reserve are returned with page->pfmemalloc
> set and it is up to the caller to determine how the page should be
> protected.  SLAB restricts access to any page with page->pfmemalloc set

pfmemalloc sounds like a page flag. If you would use one then the
preservation of the flag by copying it elsewhere may not be necessary and
the patches would be less invasive. Also you would not need to extend
and modify many of the structures.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
