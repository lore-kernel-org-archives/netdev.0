From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 14/16] dma-debug: add checks for sync_single_sg_*
Date: Sun, 11 Jan 2009 09:00:19 +0100
Message-ID: <20090111080019.GK9466@8bytes.org>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com> <1231517970-20288-15-git-send-email-joerg.roedel@amd.com> <20090110234641.GB20843@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joerg Roedel <joerg.roedel@amd.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org,
	mingo@redhat.com
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 8bytes.org ([88.198.83.132]:38444 "EHLO 8bytes.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750998AbZAKIAU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Jan 2009 03:00:20 -0500
Content-Disposition: inline
In-Reply-To: <20090110234641.GB20843@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 11, 2009 at 12:46:41AM +0100, Ingo Molnar wrote:
> 
> * Joerg Roedel <joerg.roedel@amd.com> wrote:
> 
> > +void debug_sync_sg_for_cpu(struct device *dev, struct scatterlist *sg,
> > +			   int nelems, int direction)
> > +{
> > +	struct scatterlist *s;
> > +	int i;
> > +
> > +	if (global_disable)
> > +		return;
> 
> "if (unlikely(global_disable))" i suspect?

True. I  will add unlikely() to all global_disable checks.

Joerg
