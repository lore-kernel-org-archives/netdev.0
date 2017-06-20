From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: new dma-mapping tree, was Re: clean up and modularize arch
 dma_mapping interface V2
Date: Tue, 20 Jun 2017 23:04:00 +1000
Message-ID: <20170620230400.1a5ae889@canb.auug.org.au>
References: <20170616181059.19206-1-hch@lst.de>
        <20170620124140.GA27163@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org,
        linux-arm-kernel@lists.infradead.org,
        xen-devel@lists.xenproject.org, linux-c6x-dev@linux-c6x.org,
        linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org,
        linux-mips@linux-mips.org, openrisc@lists.librecores.org,
        linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
        linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
        linux-xtensa@linux-xtensa.org, dmaengine@vger.kernel.org,
        linux-tegra@vger.kernel.org, dri-devel@lists.freedesktop.org,
        linux-samsung-soc@vger.kernel.org,
        iommu@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Marek Szyprowski <m.szyprowski@samsung.com>,
        Kyungmin Park <kyungmin.park@samsung.com>
To: Christoph Hellwig <hch@lst.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:47745 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751046AbdFTNEG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Jun 2017 09:04:06 -0400
In-Reply-To: <20170620124140.GA27163@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Christoph,

On Tue, 20 Jun 2017 14:41:40 +0200 Christoph Hellwig <hch@lst.de> wrote:
>
> On Fri, Jun 16, 2017 at 08:10:15PM +0200, Christoph Hellwig wrote:
> > I plan to create a new dma-mapping tree to collect all this work.
> > Any volunteers for co-maintainers, especially from the iommu gang?  
> 
> Ok, I've created the new tree:
> 
>    git://git.infradead.org/users/hch/dma-mapping.git for-next
> 
> Gitweb:
> 
>    http://git.infradead.org/users/hch/dma-mapping.git/shortlog/refs/heads/for-next
> 
> And below is the patch to add the MAINTAINERS entry, additions welcome.
> 
> Stephen, can you add this to linux-next?

Added from tomorrow.

I have another tree called dma-mapping:

git://git.linaro.org/people/mszyprowski/linux-dma-mapping.git#dma-mapping-next

Contacts: Marek Szyprowski and Kyungmin Park (cc'd)

I have called your tree dma-mapping-hch for now.  The other tree has
not been updated since 4.9-rc1 and I am not sure how general it is.
Marek, Kyungmin, any comments?

Thanks for adding your subsystem tree as a participant of linux-next.  As
you may know, this is not a judgement of your code.  The purpose of
linux-next is for integration testing and to lower the impact of
conflicts between subsystems in the next merge window. 

You will need to ensure that the patches/commits in your tree/series have
been:
     * submitted under GPL v2 (or later) and include the Contributor's
        Signed-off-by,
     * posted to the relevant mailing list,
     * reviewed by you (or another maintainer of your subsystem tree),
     * successfully unit tested, and 
     * destined for the current or next Linux merge window.

Basically, this should be just what you would send to Linus (or ask him
to fetch).  It is allowed to be rebased if you deem it necessary.

-- 
Cheers,
Stephen Rothwell 
sfr@canb.auug.org.au
