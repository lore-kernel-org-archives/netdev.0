From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 01/16] mm: Serialize access to min_free_kbytes
Date: Mon, 23 Apr 2012 16:50:48 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1204231623210.17030@chino.kir.corp.google.com>
References: <1334578624-23257-1-git-send-email-mgorman@suse.de> <1334578624-23257-2-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>,
    Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
    David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>,
    Peter Zijlstra <a.p.zijlstra@chello.nl>,
    Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>
To: Mel Gorman <mgorman@suse.de>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1334578624-23257-2-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, 16 Apr 2012, Mel Gorman wrote:

> There is a race between the min_free_kbytes sysctl, memory hotplug
> and transparent hugepage support enablement.  Memory hotplug uses a
> zonelists_mutex to avoid a race when building zonelists. Reuse it to
> serialise watermark updates.
> 
> [a.p.zijlstra@chello.nl: Older patch fixed the race with spinlock]
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Reviewed-by: Rik van Riel <riel@redhat.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
