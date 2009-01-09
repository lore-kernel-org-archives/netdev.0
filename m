From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 05/16] dma-debug: add initialization code
Date: Fri, 9 Jan 2009 19:17:31 +0100
Message-ID: <20090109181731.GC9466@8bytes.org>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com> <1231517970-20288-6-git-send-email-joerg.roedel@amd.com> <20090109175842.GC30168@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joerg Roedel <joerg.roedel@amd.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org,
	mingo@redhat.com
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 8bytes.org ([88.198.83.132]:52464 "EHLO 8bytes.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754860AbZAISRc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 13:17:32 -0500
Content-Disposition: inline
In-Reply-To: <20090109175842.GC30168@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 09, 2009 at 08:58:42PM +0300, Evgeniy Polyakov wrote:
> On Fri, Jan 09, 2009 at 05:19:19PM +0100, Joerg Roedel (joerg.roedel@amd.com) wrote:
>  +static int prealloc_memory(u32 num_entries)
> > +{
> > +	struct dma_debug_entry *entry, *next_entry;
> > +	int i;
> > +
> > +	for (i = 0; i < num_entries; ++i) {
> > +		entry = kmalloc(sizeof(*entry), GFP_KERNEL | __GFP_ZERO);
> 
> kzalloc?

True. kzalloc is better. I will change that.

Joerg
