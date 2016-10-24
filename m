From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [net-next PATCH RFC 01/26] swiotlb: Drop unused function
 swiotlb_map_sg
Date: Mon, 24 Oct 2016 14:10:50 -0400
Message-ID: <20161024181050.GB24840@char.us.oracle.com>
References: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
 <20161024120431.16276.89246.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, brouer@redhat.com, davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161024120431.16276.89246.stgit@ahduyck-blue-test.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 24, 2016 at 08:04:31AM -0400, Alexander Duyck wrote:
> There are no users for swiotlb_map_sg so we might as well just drop it.
> 
> Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

Acked-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

Thought I swear I saw a familiar patch by Christopher Hellwig at some point..
but maybe that patchset had been dropped.

> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---
>  include/linux/swiotlb.h |    4 ----
>  lib/swiotlb.c           |    8 --------
>  2 files changed, 12 deletions(-)
> 
> diff --git a/include/linux/swiotlb.h b/include/linux/swiotlb.h
> index 5f81f8a..e237b6f 100644
> --- a/include/linux/swiotlb.h
> +++ b/include/linux/swiotlb.h
> @@ -72,10 +72,6 @@ extern void swiotlb_unmap_page(struct device *hwdev, dma_addr_t dev_addr,
>  			       size_t size, enum dma_data_direction dir,
>  			       unsigned long attrs);
>  
> -extern int
> -swiotlb_map_sg(struct device *hwdev, struct scatterlist *sg, int nents,
> -	       enum dma_data_direction dir);
> -
>  extern void
>  swiotlb_unmap_sg(struct device *hwdev, struct scatterlist *sg, int nents,
>  		 enum dma_data_direction dir);
> diff --git a/lib/swiotlb.c b/lib/swiotlb.c
> index 22e13a0..47aad37 100644
> --- a/lib/swiotlb.c
> +++ b/lib/swiotlb.c
> @@ -910,14 +910,6 @@ void swiotlb_unmap_page(struct device *hwdev, dma_addr_t dev_addr,
>  }
>  EXPORT_SYMBOL(swiotlb_map_sg_attrs);
>  
> -int
> -swiotlb_map_sg(struct device *hwdev, struct scatterlist *sgl, int nelems,
> -	       enum dma_data_direction dir)
> -{
> -	return swiotlb_map_sg_attrs(hwdev, sgl, nelems, dir, 0);
> -}
> -EXPORT_SYMBOL(swiotlb_map_sg);
> -
>  /*
>   * Unmap a set of streaming mode DMA translations.  Again, cpu read rules
>   * concerning calls here are the same as for swiotlb_unmap_page() above.
> 
