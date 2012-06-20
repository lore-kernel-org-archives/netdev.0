From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH 12/12] Avoid dereferencing bd_disk during swap_entry_free
 for network storage
Date: Wed, 20 Jun 2012 13:47:03 -0400
Message-ID: <4FE20C97.2060401@redhat.com>
References: <1340185081-22525-1-git-send-email-mgorman@suse.de> <1340185081-22525-13-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>,
        Linux-Netdev <netdev@vger.kernel.org>,
        Linux-NFS <linux-nfs@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>,
        Peter Zijlstra <a.p.zijlstra@chello.nl>,
        Mike Christie <michaelc@cs.wisc.edu>,
        Eric B Munson <emunson@mgebm.net>
To: Mel Gorman <mgorman@suse.de>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1340185081-22525-13-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 06/20/2012 05:38 AM, Mel Gorman wrote:
> Commit [b3a27d: swap: Add swap slot free callback to
> block_device_operations] dereferences p->bdev->bd_disk but this is a
> NULL dereference if using swap-over-NFS. This patch checks SWP_BLKDEV
> on the swap_info_struct before dereferencing.
>
> With reference to this callback, Christoph Hellwig stated "Please
> just remove the callback entirely.  It has no user outside the staging
> tree and was added clearly against the rules for that staging tree".
> This would also be my preference but there was not an obvious way of
> keeping zram in staging/ happy.
>
> Signed-off-by: Xiaotian Feng<dfeng@redhat.com>
> Signed-off-by: Mel Gorman<mgorman@suse.de>

Acked-by: Rik van Riel<riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
