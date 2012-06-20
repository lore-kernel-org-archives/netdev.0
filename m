From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH 10/12] nfs: enable swap on NFS
Date: Wed, 20 Jun 2012 13:38:20 -0400
Message-ID: <4FE20A8C.6000207@redhat.com>
References: <1340185081-22525-1-git-send-email-mgorman@suse.de> <1340185081-22525-11-git-send-email-mgorman@suse.de>
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
In-Reply-To: <1340185081-22525-11-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 06/20/2012 05:37 AM, Mel Gorman wrote:
> Implement the new swapfile a_ops for NFS and hook up ->direct_IO. This
> will set the NFS socket to SOCK_MEMALLOC and run socket reconnect
> under PF_MEMALLOC as well as reset SOCK_MEMALLOC before engaging the
> protocol ->connect() method.
>
> PF_MEMALLOC should allow the allocation of struct socket and related
> objects and the early (re)setting of SOCK_MEMALLOC should allow us
> to receive the packets required for the TCP connection buildup.
>
> [dfeng@redhat.com: Fix handling of multiple swap files]
> [a.p.zijlstra@chello.nl: Original patch]
> Signed-off-by: Mel Gorman<mgorman@suse.de>

Acked-by: Rik van Riel<riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
