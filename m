From: Martin Diehl <lists@mdiehl.de>
Subject: Re: [PATCH] Drop ISA dependencies from IRDA drivers
Date: Fri, 16 Jul 2004 08:33:45 +0200 (CEST)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0407160829560.14037-100000@notebook.home.mdiehl.de>
References: <20040716061913.GB662@wotan.suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jgarzik@pobox.com>, <netdev@oss.sgi.com>,
	<irda-users@lists.sourceforge.net>,
	Jean Tourrilhes <jt@hpl.hp.com>, <the_nihilant@autistici.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S266290AbUGPG1r@vger.kernel.org>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040716061913.GB662@wotan.suse.de>
List-Id: netdev.vger.kernel.org

On Fri, 16 Jul 2004, Andi Kleen wrote:

> > According to include/asm-x86_64/dma-mapping.h there is no such override 
> > for x86-64. Hence the generic implementation is used which Oopses when 
> > called with dev=NULL in dma_alloc_coherent because it dereferences dev 
> > unconditionally.
> 
> The old pci_alloc_coherent supported hwdev == NULL under x86-64.
> dma_alloc_consistent() should too. I will fix that. 

Ok, thanks. This sounds like the right solution. I think most/all 
functions in include/asm-generic/dma-mapping.h are not prepared to accept 
dev=NULL parameters, so it's a bit more than just dma_alloc_coherent() :-(

Martin
