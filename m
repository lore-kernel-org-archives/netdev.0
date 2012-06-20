From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH 06/12] mm: Add get_kernel_page[s] for pinning of kernel
 addresses for I/O
Date: Wed, 20 Jun 2012 12:11:44 -0400
Message-ID: <4FE1F640.10803@redhat.com>
References: <1340185081-22525-1-git-send-email-mgorman@suse.de> <1340185081-22525-7-git-send-email-mgorman@suse.de>
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
In-Reply-To: <1340185081-22525-7-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 06/20/2012 05:37 AM, Mel Gorman wrote:
> This patch adds two new APIs get_kernel_pages() and get_kernel_page()
> that may be used to pin a vector of kernel addresses for IO. The initial
> user is expected to be NFS for allowing pages to be written to swap
> using aops->direct_IO(). Strictly speaking, swap-over-NFS only needs
> to pin one page for IO but it makes sense to express the API in terms
> of a vector and add a helper for pinning single pages.
>
> Signed-off-by: Mel Gorman<mgorman@suse.de>

Reviewed-by: Rik van Riel<riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
