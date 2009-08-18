From: Jens Rosenboom <jens@mcbone.net>
Subject: Re: [PATCH V2] lib/vsprintf.c: Add "%pI6c" - print pointer as
 compressed ipv6 address
Date: Tue, 18 Aug 2009 15:48:56 +0200
Message-ID: <1250603336.16632.49.camel@fnki-nb00130>
References: <1250230925.6641.92.camel@fnki-nb00130>
	 <20090814.001519.40499255.davem@davemloft.net>
	 <1250237739.16632.12.camel@fnki-nb00130>
	 <20090814.131218.139318801.davem@davemloft.net>
	 <1250349894.4620.5.camel@Joe-Laptop.home>
	 <1250522309.16632.45.camel@fnki-nb00130>
	 <1250548184.4488.6.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, chuck.lever@oracle.com,
	brian.haley@hp.com, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from leia.mcbone.net ([194.97.104.42]:50584 "EHLO leia.mcbone.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755009AbZHRNtK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2009 09:49:10 -0400
In-Reply-To: <1250548184.4488.6.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-08-17 at 15:29 -0700, Joe Perches wrote:
> On Mon, 2009-08-17 at 17:18 +0200, Jens Rosenboom wrote: 
[...]
> > Also I'm wondering whether it makes sense to pull the format code
> > checking into all the sub-routines. 
> 
> It isn't clear to me what you're asking for.
> 
> > It might be easier to maintain if it 
> > is all kept together in pointer().
> 
> Can you explain more thoroughly please?
> 
> If you mean not passing const char *fmt to the sub-routines,
> I think not doing so makes it harder to maintain and extend.
> 
> I think it will be useful to extend the 'S' resource_string
> capability to use fmt to allow specific bits to be selected
> of the resource identifier to be printed.
> 
> See the idea in:  http://lkml.org/lkml/2009/4/17/105

You were right in assuming the intention of my seemingly badly explained
comments, but in this context I agree with you, that it makes sense the
way you did it.

> Here's the modified patch with your suggestions:
> 

Ran it through my test-cases and they all look fine.

Tested-by: Jens Rosenboom <jens@mcbone.net>

