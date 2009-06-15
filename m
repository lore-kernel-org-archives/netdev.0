From: Subrata Modak <subrata@linux.vnet.ibm.com>
Subject: Re: [PATCH][BUILD FAILURE 03/04] Next June 04:PPC64 randconfig
	[drivers/net/lance.o]
Date: Mon, 15 Jun 2009 12:51:49 +0530
Message-ID: <1245050509.5239.11.camel@subratamodak.linux.ibm.com>
References: <20090611035046.22125.26641.sendpatchset@subratamodak.linux.ibm.com>
	 <1245048698.5239.9.camel@subratamodak.linux.ibm.com>
	 <1245049899.19217.56.camel@pasglop>
Reply-To: subrata@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Paul Mackerras <paulus@samba.org>,
	Linuxppc-dev <Linuxppc-dev@ozlabs.org>,
	Sachin P Sant <sachinp@linux.vnet.ibm.com>,
	Linux-Kernel <linux-kernel@vger.kernel.org>,
	Linux-Next <linux-next@vger.kernel.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Balbir Singh <balbir@linux.vnet.ibm.com>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1245049899.19217.56.camel@pasglop>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2009-06-15 at 17:11 +1000, Benjamin Herrenschmidt wrote:
> On Mon, 2009-06-15 at 12:21 +0530, Subrata Modak wrote:
> 
> > Benjamin,
> > 
> > I am not sure whether you liked the following patch to solve the above
> > problem. Do, you want me address some other issue(s)/fixes for this ?
> 
> I suppose ... in fact some old PReP machines can even have ISA slots
> iirc, but it's not going to do good with machines that have an iommu...
> 
> IE. Nobody should use that crap, period.

Great,

Can you please make some changes at drivers/net/Kconfig so that this guy
does not build for the PPC64 systems ?

Regards--
Subrata

> 
> Cheers,
> Ben.
> 
> Cheers,
> Ben.
> 
> > Regards--
> > Subrata
> > 
> > > 
> > > --- linux-2.6.30-rc8/arch/powerpc/include/asm/io.h.orig	2009-06-10 21:56:49.000000000 -0500
> > > +++ linux-2.6.30-rc8/arch/powerpc/include/asm/io.h	2009-06-10 22:21:35.000000000 -0500
> > > @@ -680,6 +680,9 @@ extern void __iounmap_at(void *ea, unsig
> > >  #define mmio_outsw(addr, src, count)	writesw(addr, src, count)
> > >  #define mmio_outsl(addr, src, count)	writesl(addr, src, count)
> > > 
> > > +#define isa_virt_to_bus		virt_to_phys
> > > +#define isa_bus_to_virt		phys_to_virt
> > > +
> > >  /**
> > >   *	virt_to_phys	-	map virtual addresses to physical
> > >   *	@address: address to remap
> > > 
> > > ---
> > > Regards--
> > > Subrata
> > > 
> 
