From: Jon Masters <jonathan@jonmasters.org>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Tue, 27 Nov 2007 17:31:38 -0500
Message-ID: <1196202698.3415.119.camel__11070.5670821064$1196204685$gmane$org@jcmlaptop>
References: <20071122343.446909000@suse.de>
	 <200711261228.15155.rusty@rustcorp.com.au> <adahcj9sfan.fsf@cisco.com>
	 <200711271549.37670.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <rdreier@cisco.com>, Andi Kleen <ak@suse.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from panic.printk.net ([217.147.83.20]:35783 "EHLO panic.printk.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752592AbXK0XEQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2007 18:04:16 -0500
In-Reply-To: <200711271549.37670.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-11-27 at 15:49 +1100, Rusty Russell wrote:
> On Monday 26 November 2007 17:15:44 Roland Dreier wrote:

> > It seems pretty   
> > clear to me that having a mechanism that requires modules to make
> > explicit which (semi-)internal APIs makes reviewing easier
> 
> Perhaps you've got lots of patches were people are using internal APIs they 
> shouldn't?

With my "Enterprise" hat on, I can see where Andi was coming from
originally. Just like we do in RHEL, SuSE have a concept of a kernel ABI
and we too have a concept of a whitelist of symbols - a subset of kernel
ABI that is approved for use by third parties (this is nothing to do
with licensing, this is to do with ABI stability we try to ensure).

As part of figuring out what should and should not be used by external
modules (outside of the core kernel), we've gained a bit of experience,
and it would be nice to be able to help others - this is nothing to do
with upstream "ABI stability", but just to be of a public service by
documenting those functions that are never intended for modules but
which necessarily are exported because they have one or two users.

> > , makes it 
> > easier to communicate "please don't use that API" to module authors,
> 
> Well, introduce an EXPORT_SYMBOL_INTERNAL().  It's a lot less code.  But you'd 
> still need to show that people are having trouble knowing what APIs to use.

I suggested this exact idea privately at OLS. I still think it's the
best compromise, though I like bits of the namespace idea. An
EXPORT_SYMBOL_INTERNAL would indeed be trivial.

Jon.


