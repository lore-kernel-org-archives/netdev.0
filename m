From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: linux-next: build failure after merge of the final tree
 (net-next tree related)
Date: Sun, 23 Sep 2012 07:20:07 +1000
Message-ID: <1348348807.1132.76.camel@pasglop>
References: <1348179764.1132.35.camel@pasglop>
	 <20120920.185315.576326460331670020.davem@davemloft.net>
	 <1348264000.1132.63.camel@pasglop>
	 <20120922.160027.1528491047223302539.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, paulus@samba.org,
	linuxppc-dev@lists.ozlabs.org, mika.westerberg@linux.intel.com,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20120922.160027.1528491047223302539.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2012-09-22 at 16:00 -0400, David Miller wrote:
> 
> I think I'm going to just end up restricting this driver to X86
> as was originally suggested.

Probably the easiest fix indeed.

> There seems to be no real consistent Kconfig protection for users
> of isa_virt_to_bus() and friends.
> 
> We know that ISA_DMA_API doesn't do it, and ISA doesn't do it either
> as powerpc also allows that to bet set for CHRP and friends.

It's a old mess :-( And not an easy one to untangle...

Cheers,
Ben.
