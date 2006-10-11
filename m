From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 21/21]: powerpc/cell spidernet DMA coalescing
Date: Wed, 11 Oct 2006 17:15:10 +1000
Message-ID: <1160550910.6177.66.camel@localhost.localdomain>
References: <20061010204946.GW4381@austin.ibm.com>
	 <20061010212324.GR4381@austin.ibm.com>  <452C2AAA.5070001@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linas Vepstas <linas@austin.ibm.com>, akpm@osdl.org,
	jeff@garzik.org, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, James K Lewis <jklewis@us.ibm.com>,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:46057 "EHLO gate.crashing.org")
	by vger.kernel.org with ESMTP id S1030675AbWJKHQI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2006 03:16:08 -0400
To: jschopp <jschopp@austin.ibm.com>
In-Reply-To: <452C2AAA.5070001@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-10-10 at 18:20 -0500, jschopp wrote:
> Linas Vepstas wrote:
> > The current driver code performs 512 DMA mappns of a bunch of 
> > 32-byte structures. This is silly, as they are all in contiguous 
> > memory. Ths patch changes the code to DMA map the entie area
> > with just one call.
> > 
> > Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
> > Cc: James K Lewis <jklewis@us.ibm.com>
> > Cc: Arnd Bergmann <arnd@arndb.de>
> 
> The others look good, but this one complicates the code and doesn't have any benefit.  20 
> for 21 isn't bad.

Hi Joel !

I'm not sure what you mean here.... (especially your 20 to 21 comment).

The patch looks perfectly fine to me, and in fact removes more lines of
code than it adds :)

Cheers,
Ben.


