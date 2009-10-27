From: Benjamin LaHaise <bcrl@lhnet.ca>
Subject: Re: [RFC PATCH] fib_hash: improve route deletion scaling on interface drop with lots of interfaces
Date: Tue, 27 Oct 2009 10:24:26 -0400
Message-ID: <20091027142426.GB3141@kvack.org>
References: <20091027000302.GA3141@kvack.org> <20091026.171749.106971240.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:33227 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752947AbZJ0OYX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Oct 2009 10:24:23 -0400
Content-Disposition: inline
In-Reply-To: <20091026.171749.106971240.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 26, 2009 at 05:17:49PM -0700, David Miller wrote:
> > bottleneck.  Next up in the network code is rt_cache_flush().  Comments?
> 
> On a real router adding and removing routes is happening a lot
> whereas interface changes are rare.  You're making a more common
> operation more expensive for the sake of a less common one.

It's not a question of more common vs less common, but if the system can 
recover from an adverse event within a reasonable amount of time.  Tunnel 
flaps occur in the real world, and this results in the change of state of 
a large number of interfaces at the same time.  Would it be okay if this 
is wrapped in a config option?  I agree that the extra overhead is not 
for everyone.

> Please put local variable lines that are longer at the beginning of
> the list of variable declarations at the top of a function, not the
> other way around which stands out like a sore thumb and looks ugly.

Whoops, will fix.

		-ben
