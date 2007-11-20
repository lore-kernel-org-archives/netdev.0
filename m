From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-2.6.25 0/4] Convert IP4 address class macros to inline functions
Date: Tue, 20 Nov 2007 16:06:03 +0900
Message-ID: <20071120070601.GE10490@verge.net.au>
References: <1195540812.4675.89.camel@localhost>
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
Received: from koto.vergenet.net ([210.128.90.7]:44613 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756624AbXKTHGG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2007 02:06:06 -0500
Content-Disposition: inline
In-Reply-To: <1195540812.4675.89.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 19, 2007 at 10:40:12PM -0800, Joe Perches wrote:
> Change LOOPBACK MULTICAST LOCAL_MCAST BADCLASS and ZERONET
> macros to inline functions ipv4_is_<type>(__be32 addr)
> 
> Adds some type safety and arguably some readability
> 
> No change in compiled image size
> 
> Signed-off-by: Joe Perches <joe@perches.com>

I can understand the motivation for moving the functionality into
inline functions in order to get some type safety. But what is
the motivation for changing all the macro calls to function calls,
when you have set up the marcos to call the appropriate functions?
Surely if you want to do that you should just ditch the marcos all
together. Perhaps I am missing a patch?

Also, as the function names are longer than the macro name
you are creating lines that are > 80 columns wide that used
not to be in that state. For my eyes that reduced readability
(substantially).

-- 
Horms

