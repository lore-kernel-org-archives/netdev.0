From: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Subject: Re: [PATCH 06/44] iommu/dma: don't rely on DMA_ERROR_CODE
Date: Fri, 16 Jun 2017 10:37:00 +0200
Message-ID: <20170616083700.GA10582@lst.de>
References: <20170608132609.32662-1-hch@lst.de>
	<20170608132609.32662-7-hch@lst.de>
	<0bfb0841-f054-78de-628d-a0955336bcb4@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-samsung-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-c6x-dev-jPsnJVOj+W6hPH1hqNUYSQ@public.gmane.org,
	linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-hexagon-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org,
	x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org,
	dmaengine-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	openrisc-cunTk1MwBs9a3B2Vnqf2dGD2FQJk+8+b@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Robin Murphy <robin.murphy-5wv7dgnIgG8@public.gmane.org>
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <0bfb0841-f054-78de-628d-a0955336bcb4-5wv7dgnIgG8@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 08, 2017 at 02:59:07PM +0100, Robin Murphy wrote:
> Hi Christoph,
> 
> On 08/06/17 14:25, Christoph Hellwig wrote:
> > DMA_ERROR_CODE is not a public API and will go away soon.  dma dma-iommu
> > driver already implements a proper ->mapping_error method, so it's only
> > using the value internally.  Add a new local define using the value
> > that arm64 which is the only current user of dma-iommu.
> 
> It would be fine to just use 0, since dma-iommu already makes sure that
> that will never be allocated for a valid DMA address.

I'll change it to 0.

> Otherwise, looks good!

Can you give me a formal ACK or Reviewed-by: ?
