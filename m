From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH 01/17] mm: sl[au]b: Add knowledge of PFMEMALLOC reserve
 pages
Date: Thu, 21 Jun 2012 17:30:56 -0400
Message-ID: <4FE39290.8020609@redhat.com>
References: <1340192652-31658-1-git-send-email-mgorman@suse.de> <1340192652-31658-2-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>,
        Linux-Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>,
        Peter Zijlstra <a.p.zijlstra@chello.nl>,
        Mike Christie <michaelc@cs.wisc.edu>,
        Eric B Munson <emunson@mgebm.net>,
        Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
To: Mel Gorman <mgorman@suse.de>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1340192652-31658-2-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 06/20/2012 07:43 AM, Mel Gorman wrote:

> +/* Clears ac->pfmemalloc if no slabs have pfmalloc set */
> +static void check_ac_pfmemalloc(struct kmem_cache *cachep,
> +						struct array_cache *ac)
> +{

> +	pfmemalloc_active = false;
> +out:
> +	spin_unlock_irqrestore(&l3->list_lock, flags);
> +}

The comment and the function do not seem to match.

Otherwise, the patch looks reasonable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
