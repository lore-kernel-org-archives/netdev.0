From: Joerg Roedel <joerg.roedel@amd.com>
Subject: Re: [PATCH 02/10] x86: add data structures for DMA-API debugging
Date: Fri, 21 Nov 2008 17:49:23 +0100
Message-ID: <20081121164923.GC1386@amd.com>
References: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com> <1227284770-19215-3-git-send-email-joerg.roedel@amd.com> <20081121164254.GC733@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Ingo Molnar <mingo@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	iommu@lists.linux-foundation.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-wa4.frontbridge.com ([216.32.181.16]:10318 "EHLO
	WA4EHSOBE001.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756603AbYKUQte (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 11:49:34 -0500
Content-Disposition: inline
In-Reply-To: <20081121164254.GC733@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 21, 2008 at 05:42:54PM +0100, Ingo Molnar wrote:
> 
> * Joerg Roedel <joerg.roedel@amd.com> wrote:
> 
> > +#ifndef __ASM_X86_DMA_DEBUG
> > +#define __ASM_X86_DMA_DEBUG
> > +
> > +/* Allocation flags */
> > +#define DMA_DEBUG_SINGLE        0
> > +#define DMA_DEBUG_SG            1
> > +#define DMA_DEBUG_COHERENT      2
> 
> please use enum for such internal flags, not define.
> 
> > +
> > +struct device;
> > +struct list_head;
> > +
> > +struct dma_debug_entry {
> > +	struct list_head list;
> > +	struct device *dev;
> > +	int type;
> > +	void *cpu_addr;
> > +	u64 dev_addr;
> > +	u64 size;
> > +	int direction;
> > +};
> 
> please align new x86/include structures vertically like this:
> 
> > +struct dma_debug_entry {
> > +	struct list_head	list;
> > +	struct device		*dev;
> > +	int			type;
> > +	void			*cpu_addr;
> > +	u64			dev_addr;
> > +	u64			size;
> > +	int			direction;
> > +};
> 
> [ for the arts major students reading lkml ;-) ]

Ok, I will update the patch :)

Joerg

-- 
           |           AMD Saxony Limited Liability Company & Co. KG
 Operating |         Wilschdorfer Landstr. 101, 01109 Dresden, Germany
 System    |                  Register Court Dresden: HRA 4896
 Research  |              General Partner authorized to represent:
 Center    |             AMD Saxony LLC (Wilmington, Delaware, US)
           | General Manager of AMD Saxony LLC: Dr. Hans-R. Deppe, Thomas McCoy

