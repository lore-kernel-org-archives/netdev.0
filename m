From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH V2] net: ethernet: mellanox: correct page conversion
Date: Mon, 18 Apr 2016 06:10:58 -0700
Message-ID: <20160418131058.GA25421@infradead.org>
References: <1460845412-13120-1-git-send-email-okaya@codeaurora.org>
 <20160418121247.GA25387@infradead.org>
 <0c6a430c5f0ec64f51d7c594ef9751dd@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, linux-rdma@vger.kernel.org,
	timur@codeaurora.org, cov@codeaurora.org,
	Yishai Hadas <yishaih@mellanox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: okaya@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <0c6a430c5f0ec64f51d7c594ef9751dd@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 18, 2016 at 09:06:18AM -0400, okaya@codeaurora.org wrote:
> On 2016-04-18 08:12, Christoph Hellwig wrote:
> >On Sat, Apr 16, 2016 at 06:23:32PM -0400, Sinan Kaya wrote:
> >>Current code is assuming that the address returned by dma_alloc_coherent
> >>is a logical address. This is not true on ARM/ARM64 systems.
> >
> >Can you explain what you mean with a 'logical address' and what actual
> >issue you're trying to solve?
> 
> Vmap call is failing on arm64 systems because dma alloc api already returns
> an address mapped with vmap.

Please state your problem clearly.  What I'm reverse engineering from
your posts is:  because dma_alloc_coherent uses vmap-like mappings on
arm64 (all, some systems?) a driver using a lot of them might run into
limits of the vmap pool size.

Is this correct?

> 
> Please see arch/arm64/mm directory.
---end quoted text---
