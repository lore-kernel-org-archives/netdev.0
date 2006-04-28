From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 3/32] rt2x00: use pci_*_consistent for DMA mapping
Date: Fri, 28 Apr 2006 14:15:33 +0100
Message-ID: <20060428131533.GB3288@infradead.org>
References: <200604280002.52839.IvDoorn@gmail.com> <20060427221127.GA22135@infradead.org> <200604281457.35460.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, netdev@vger.kernel.org,
	rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:31695 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1030388AbWD1NPe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Apr 2006 09:15:34 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
Content-Disposition: inline
In-Reply-To: <200604281457.35460.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 28, 2006 at 02:57:31PM +0200, Ivo van Doorn wrote:
> On Friday 28 April 2006 00:11, Christoph Hellwig wrote:
> > On Fri, Apr 28, 2006 at 12:02:52AM +0200, Ivo van Doorn wrote:
> > > From: Ivo van Doorn <IvDoorn@gmail.com>
> > > 
> > > Instead of dma_*_coherent
> > > use pci_*consistent functions.
> > 
> > No point in doing that, quite reverse as you use the gfp_mask argument
> > which is a (small) pessimation here.
> 
> Would it be recommended that I replace the usb_alloc_buffers in the
> rt2570 driver with dma_*coherent?
> This would get the dma rings allocation and freeing a bit more generic
> between PCI and USB and could reduce some duplicate code between them.
> But I am not sure if there is any major difference between the two.

I don't have the full code for your driver anywhere near me so I can't
comment on this.  Maybe you could send the code of 'usb_alloc_buffers'
for comments?



---end quoted text---
