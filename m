From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-2.6.25 0/4] Convert IP4 address class macros to inline functions
Date: Tue, 20 Nov 2007 16:42:33 +0900
Message-ID: <20071120074231.GB3402@verge.net.au>
References: <1195540812.4675.89.camel@localhost> <20071120070601.GE10490@verge.net.au> <1195543124.4675.114.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@coreworks.de>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:44780 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755484AbXKTHme (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2007 02:42:34 -0500
Content-Disposition: inline
In-Reply-To: <1195543124.4675.114.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 19, 2007 at 11:18:44PM -0800, Joe Perches wrote:
> On Tue, 2007-11-20 at 16:06 +0900, Simon Horman wrote:
> > On Mon, Nov 19, 2007 at 10:40:12PM -0800, Joe Perches wrote:
> > > Change LOOPBACK MULTICAST LOCAL_MCAST BADCLASS and ZERONET
> > > macros to inline functions ipv4_is_<type>(__be32 addr)
> > > Adds some type safety and arguably some readability
> > > No change in compiled image size
> > > Signed-off-by: Joe Perches <joe@perches.com>
> > I can understand the motivation for moving the functionality into
> > inline functions in order to get some type safety. But what is
> > the motivation for changing all the macro calls to function calls,
> > when you have set up the marcos to call the appropriate functions?
> 
> It's just a sequence that allows the kernel to compile.
> 
> I expect to remove the macros when the other callsites,
> drivers/infiniband and drivers/parisc, are converted.
> 
> > Surely if you want to do that you should just ditch the marcos all
> > together. Perhaps I am missing a patch?
> 
> That's what I'd like to do but in sequence.
> 
> David Miller can reasonably accept the net changes, but
> I'm not too sure he can accept the drivers changes.
> 
> If/when this change is accepted and patches for drivers are
> accepted, I'll submit a patch to remove the macros.

Thanks for the clarification. I realised after I sent my
mail that you were probably having to cope with other callers.

> > Also, as the function names are longer than the macro name
> > you are creating lines that are > 80 columns wide that used
> > not to be in that state. For my eyes that reduced readability
> > (substantially).
> 
> David? You want a patch for that too?

-- 
Horms

