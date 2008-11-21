From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 0/10] DMA-API debugging facility
Date: Fri, 21 Nov 2008 18:03:21 +0100
Message-ID: <20081121170321.GH733@elte.hu>
References: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com> <1227286492.4901.208.camel@macbook.infradead.org> <20081121165722.GD1386@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Woodhouse <dwmw2@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org
To: Joerg Roedel <joerg.roedel@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:53107 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752705AbYKURDj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 12:03:39 -0500
Content-Disposition: inline
In-Reply-To: <20081121165722.GD1386@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Joerg Roedel <joerg.roedel@amd.com> wrote:

> On Fri, Nov 21, 2008 at 04:54:52PM +0000, David Woodhouse wrote:
> > On Fri, 2008-11-21 at 17:26 +0100, Joerg Roedel wrote:
> > > this patchset introduces code to debug drivers usage of the DMA-API.
> > > Tests with hardware IOMMUs have shown several bugs in drivers
> > > regarding the usage of that API.
> > > Problems were found especially in network card drivers.
> > 
> > This is really useful -- but surely it shouldn't be x86-specific?
> > 
> > All the code except the hooks in the architecture's dma_map_single() et
> > al functions could be generic, couldn't it?
> 
> Yes, in principle we could move most of it to generic code. There is 
> nothing architecture specific in it. Anybody who prefers this to be 
> arch/x86 before moving it to lib/?

yeah, we want to make it generic once it works.

but my comments about the allocation needs to be addressed (see my 
comments on [03/10]), and solving that will likely impact the 
structure of the approach in a way that will generalize it anyway, as 
a side-effect.

	Ingo
