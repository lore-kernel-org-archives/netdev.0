From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: linux-next: build failure after merge of the final tree
 (net-next tree related)
Date: Fri, 21 Sep 2012 08:22:44 +1000
Message-ID: <1348179764.1132.35.camel@pasglop>
References: <20120920173622.2aa7209cd241a3945f4384d4@canb.auug.org.au>
	 <20120920091013.GV15548@intel.com>
	 <20120920.164558.2281417114805373564.davem@davemloft.net>
	 <20120921081531.67db8a7d0ac1b35426b22c45@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org,
	David Miller <davem@davemloft.net>,
	mika.westerberg@linux.intel.com, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120921081531.67db8a7d0ac1b35426b22c45@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> > I think the powerpc port is at fault here.
> > 
> > Part of being able to advertise ISA_DMA_API is providing isa_virt_to_bus().

Hrm, that's ancient gunk, I'll have to dig. We potentially can support
ISA devices DMA'ing from an ISA bridge... but via the iommu, which means
isa_virt_to_bus is a non-starter.

But then, do we really care ? IE. Is there single device that actually
requires ISA_DMA_API and that is expected to work on any currently
supported powerpc hw ? :-)

We don't even support PReP anymore, so that leaves us with what ?

Anybody has an objection to turning ISA_DMA_API off ?

Cheers,
Ben.
