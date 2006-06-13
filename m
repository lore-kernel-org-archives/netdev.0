From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Using netconsole for debugging suspend/resume
Date: Tue, 13 Jun 2006 08:18:19 +0100
Message-ID: <20060613071819.GB16358@infradead.org>
References: <200606130547.49624.ak@suse.de> <20060612.214948.124554804.davem@davemloft.net> <200606130654.14477.ak@suse.de> <20060612.220346.71553967.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ak@suse.de, jeremy@goop.org, lkml@rtr.ca, mpm@selenic.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:16620 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S932945AbWFMHSf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jun 2006 03:18:35 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060612.220346.71553967.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 12, 2006 at 10:03:46PM -0700, David Miller wrote:
> From: Andi Kleen <ak@suse.de>
> Date: Tue, 13 Jun 2006 06:54:14 +0200
> 
> > I guess if you use 1394 with remote DMA for other protocols (like
> > video etc.) there must be some way for the subsystem to map
> > the memory even on IOMMU systems. I admit I haven't dived that
> > deeply into the 1394 subsystem so I don't know how that works.
> 
> Video-1394 has it's own driver, which does a consistent DMA
> allocation, and then maps that into userspace using remap_pfn_range().
> Entirely portable.

That's actually not portable to certain arm platforms, but that's
a different story.

