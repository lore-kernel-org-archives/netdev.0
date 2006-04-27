From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 3/32] rt2x00: use pci_*_consistent for DMA mapping
Date: Thu, 27 Apr 2006 23:11:27 +0100
Message-ID: <20060427221127.GA22135@infradead.org>
References: <200604280002.52839.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:38888 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1751811AbWD0WL3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Apr 2006 18:11:29 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
Content-Disposition: inline
In-Reply-To: <200604280002.52839.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 28, 2006 at 12:02:52AM +0200, Ivo van Doorn wrote:
> From: Ivo van Doorn <IvDoorn@gmail.com>
> 
> Instead of dma_*_coherent
> use pci_*consistent functions.

No point in doing that, quite reverse as you use the gfp_mask argument
which is a (small) pessimation here.

