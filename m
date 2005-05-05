From: Andi Kleen <ak@muc.de>
Subject: Re: Mystery packet killing tg3
Date: 5 May 2005 20:01:06 +0200
Message-ID: <20050505180106.GA24386@muc.de>
References: <20050502162405.65dfb4a9@localhost.localdomain> <20050502200251.38271b61.davem@davemloft.net> <m14qdiyhcn.fsf@muc.de> <42791825.2080204@pantasys.com> <20050505114327.GA51761@muc.de> <427A47C9.6040302@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Buckingham <peter@pantasys.com>,
        "David S. Miller" <davem@davemloft.net>, jgarzik@pobox.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
Date: Thu, 5 May 2005 20:01:06 +0200
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <427A47C9.6040302@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, May 05, 2005 at 09:20:25AM -0700, Stephen Hemminger wrote:
> Andi Kleen wrote:
> 
> >>>IOMMU code on x86-64 should be never active unless Stephen
> >>>used IOMMU_DEBUG or iommu=force.  THat is because the tg3
> >>>is a 64bit capable device and should always use bypass.
> >>>      
> >>>
> >>how is this detected? we have a board that is using a 32bit e1000 and we 
> >>have to use iommu=force otherwise it doesn't do the right thing with > 
> >>4GB of RAM.
> >>    
> >>
> >
> >"32bit e1000"? How did you get such a beast? AFAIK all e1000s are 64bit
> >address capable. Please supply a full boot log without iommu=force 
> >and describe what happens exactly.
> >  
> >
> One of the osdl e1000's in the lab is an IBM rebranded card that although
> it uses a 64bit slot, is really only 32bit

Ok, but it still supports DAC. The PCI bus width is a different
thing from the size of the address registers.

What we are talking about here is just if the card can directly
address physical memory above 4GB. What width the bus is 
is a hardware internal thing that we do not really care about
in the IOMMU code.

-Andi
