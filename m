From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/17] net: Introduce sk_gfp_atomic() to allow addition
 of GFP flags depending on the individual socket
Date: Thu, 17 May 2012 16:10:40 -0400 (EDT)
Message-ID: <20120517.161040.1412806690395517745.davem@davemloft.net>
References: <1337266231-8031-1-git-send-email-mgorman@suse.de>
	<1337266231-8031-9-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, neilb@suse.de, a.p.zijlstra@chello.nl,
        michaelc@cs.wisc.edu, emunson@mgebm.net
To: mgorman@suse.de
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1337266231-8031-9-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: Mel Gorman <mgorman@suse.de>
Date: Thu, 17 May 2012 15:50:22 +0100

> Introduce sk_gfp_atomic(), this function allows to inject sock specific
> flags to each sock related allocation. It is only used on allocation
> paths that may be required for writing pages back to network storage.
> 
> [davem@davemloft.net: Use sk_gfp_atomic only when necessary]
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
