From: Martin Diehl <lists@mdiehl.de>
Subject: Re: [irda-users] [PATCH] Make VLSI FIR depend on X86
Date: Tue, 21 Oct 2003 09:12:53 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0310210858550.4246-100000@notebook.home.mdiehl.de>
References: <20031020211706.5be33474.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Martin Diehl <lists@mdiehl.de>, <noah@caltech.edu>,
        <irda-users@lists.sourceforge.net>, <netdev@oss.sgi.com>,
        <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031020211706.5be33474.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 20 Oct 2003, David S. Miller wrote:

> On Mon, 20 Oct 2003 19:30:33 +0200 (CEST)
> Martin Diehl <lists@mdiehl.de> wrote:
> 
> > Well, it would work with any arch, _if_ there was a way to sync the 
> > streaming pci dma buffers before giving them back to hardware.
> 
> If pci_dma_sync() doesn't perform the operation you want, please
> describe what that operation is.
> 

Last time I checked pci_dma_sync was meant to sync the mapping when 
ownership gets transferred from busmaster to cpu, i.e. after hardware 
used/modified the buffer. What about the other direction when the cpu 
filled a reused streaming map to device and wants to pass ownership to the 
busmaster - we need to flush cpu caches to make sure the busmaster sees 
the modified data.

<http://marc.theaimsgroup.com/?l=linux-kernel&amp;m=103221032617171&amp;w=2>
<http://marc.theaimsgroup.com/?l=linux-kernel&amp;m=103221300019951&amp;w=2>

Did I miss something?

Thanks,
Martin
