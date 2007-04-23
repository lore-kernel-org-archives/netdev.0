From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: net-2.6.22 UDP stalls/hangs
Date: Mon, 23 Apr 2007 14:45:57 -0700
Message-ID: <20070423144557.8c74c4b0.akpm@linux-foundation.org>
References: <20070423132719.b7cf1c9e.akpm@linux-foundation.org>
	<20070423.133730.115642229.davem@davemloft.net>
	<20070423135639.26ca125a.akpm@linux-foundation.org>
	<20070423.141706.92341313.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:55301 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754183AbXDWVqJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2007 17:46:09 -0400
In-Reply-To: <20070423.141706.92341313.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 23 Apr 2007 14:17:06 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> > Is nscd the caching named which you're referring to?
> 
> I would respond, but I first checked how many responses show up when
> giving "caching named fedora" to google, and decided that you can
> figure it out yourself :-)
> 
> More seriously, you need to install the "caching-nameserver" package
> it appears, on Fedora.

The machine on which I'd need to run the caching nameserver is in fact
running hacked-about Ubuntu.  It's on the corporate network so I risk being
chased by angry people with pointy sticks and `apt-cache search nameserver'
and `apt-cache search caching' don't come up with anything useful.

Sigh.  Looks like I'll need to drag in the hub from home tomorrow.

Or git-bisect.  Seems that rc7-mm1 isn't getting any closer.  I guess I'll
need to drop git-net and git-wireless and a bunch of other stuff for now so
I can get in and diagnose all the other bugs.


Let me play around with udpspam a bit.  It doesn't _have_ to be the
resolver.  Are there any simple UDP-based client/server test apps around?
