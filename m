From: David Miller <davem@davemloft.net>
Subject: Re: [UNTESTED] gro: Add page frag support
Date: Mon, 29 Dec 2008 23:07:03 -0800 (PST)
Message-ID: <20081229.230703.265458431.davem@davemloft.net>
References: <20081226225157.GA22866@gondor.apana.org.au>
	<20081229122445.GA11161@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53544
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751629AbYL3HHA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2008 02:07:00 -0500
In-Reply-To: <20081229122445.GA11161@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 29 Dec 2008 23:24:46 +1100

> On Sat, Dec 27, 2008 at 09:51:57AM +1100, Herbert Xu wrote:
> > 
> > This patch is totally untested so please don't apply it.  I need
> > to hack the e1000e driver to not make skbs before I can test it.
> 
> OK I've tested it with a hacked e1000e driver, which indeed revealed
> a gaping hole in my design :) The pages interface needs to have some
> extra fields for the checksum information.
> 
> Here's a patch that actually works.
> 
>     gro: Use gso_size to store MSS
>     
>     In order to allow GRO packets without frag_list at all, we need to
>     store the MSS in the packet itself.  The obvious place is gso_size.
>     The only thing to watch out for is if the packet ends up not being
>     GRO then we need to clear gso_size before pushing the packet into
>     the stack.
 ...
> And the real thing.

This work looks great to me Herbert.

When you want me to apply this stuff, send them as two
seperate changes with updated commit messages.

Thanks a lot!
