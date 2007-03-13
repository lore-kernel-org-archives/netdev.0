From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Removal of multipath cached (was Re: [PATCH] [REVISED]
 net/ipv4/multipath_wrandom.c: check kmalloc() return value.)
Date: Mon, 12 Mar 2007 22:22:36 -0800
Message-ID: <20070312222236.860fc180.akpm@linux-foundation.org>
References: <20070308.232908.92582631.davem@davemloft.net>
	<20070312115137.GA3270@ff.dom.local>
	<20070312.135311.71086996.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jarkao2@o2.pl, amit2030@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:33345 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753026AbXCMFZz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2007 01:25:55 -0400
In-Reply-To: <20070312.135311.71086996.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Mon, 12 Mar 2007 13:53:11 -0700 (PDT) David Miller <davem@davemloft.net> wrote:
> From: Jarek Poplawski <jarkao2@o2.pl>
> Date: Mon, 12 Mar 2007 12:51:37 +0100
> 
> > But until then it'll unnecessarily spoil linux opinion as regards
> > stability and waste time of developers to check error messages.
> > So, maybe it's less evil to check those NULLs where possible and add
> > some WARN_ONs here and there...
> 
> It's a crash either way, so zero improvement.
> 
> And _THIS_ is my big problem with the multi-path cached code in the
> kernel.
> 
> NOBODY wants to step up and fix the code, but people refuse to let it
> get removed from the tree.  That is totally unacceptable, so I'm going
> to FIX THIS.
> 
> I'm going to FIX IT by saying that if nobody steps up to the plate to
> fix the multipath cached code by 2.6.23 IT IS GONE forver.
> 
> And there is absolutely no negotiations about this, I've held back on
> this for nearly 2 years, and nothing has happened, this code is not
> maintained, nobody cares enough to fix the bugs, and even no
> distributions enable it because it causes crashes.

Good stuff.

I suggest you put a big printk explaining the above into 2.6.21.
