From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Sat, 24 Nov 2007 15:53:34 +1100
Message-ID: <200711241553.34744.rusty@rustcorp.com.au>
References: <20071122343.446909000@suse.de> <200711231435.05788.rusty@rustcorp.com.au> <20071123195330.GA24223@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@suse.de>, Christoph Hellwig <hch@infradead.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:37400 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751204AbXKXEyA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2007 23:54:00 -0500
In-Reply-To: <20071123195330.GA24223@one.firstfloor.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 24 November 2007 06:53:30 Andi Kleen wrote:
> This serves as a documentation 
> on what is considered internal. And if some obscure module (in or
> out of tree) wants to use an internal interface they first have
> to send the module maintainer a patch and get some review this way.

So, you're saying that there's a problem with in-tree modules using symbols 
they shouldn't?  Can you give an example?

> I believe that is fairly important in tree too because the
> kernel has become so big now that review cannot be the only
> enforcement mechanism for this anymore.

If people aren't reviewing, this won't make them review.  I don't think the 
problem is that people are conniving to avoid review.

> Another secondary reason is that there are too many exported interfaces
> in general.

Probably, but this doesn't reduce it.  

> Several distributions have policies that require to 
> keep the changes to these exported interfaces minimal and that
> is very hard with thousands of exported symbol.  With name spaces
> the number of truly publicly exported symbols will hopefully
> shrink to a much smaller, more manageable set.

*This* makes sense.  But it's not clear that the burden should be placed on 
kernel coders.  You can create a list yourself.  How do I tell the difference 
between "truly publicly exported" symbols and others?

If a symbol has more than one in-tree user, it's hard to argue against an 
out-of-tree module using the symbol, unless you're arguing against *all* 
out-of-tree modules.

Sorry,
Rusty.
