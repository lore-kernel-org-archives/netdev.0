From: Martin Diehl <lists@mdiehl.de>
Subject: Re: [irda-users] [PATCH] Make VLSI FIR depend on X86
Date: Tue, 21 Oct 2003 09:33:24 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0310210929350.4246-100000@notebook.home.mdiehl.de>
References: <20031021001241.390a16df.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Martin Diehl <lists@mdiehl.de>, <noah@caltech.edu>,
        <irda-users@lists.sourceforge.net>, <netdev@oss.sgi.com>,
        <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031021001241.390a16df.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 21 Oct 2003, David S. Miller wrote:

> Here, do this, add a new interface called pci_dma_sync_to_device()
> with the appropriate args.  Add a NOP implementation to asm-i386/pci.h
> and suitable documentation changes to Documentation/DMA-mapping.txt
> 
> When you send me that patch, I'll work with the platform maintainers
> to take care of the rest.
> 
> Deal?

Ok, Thanks. Will do it.

One more question: Shouldn't the i386 implementation instead of being NOP 
just call flush_write_buffers() - at least this is what the vlsi-private 
implementation is doing at the moment?

Martin
