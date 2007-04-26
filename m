From: Greg KH <greg@kroah.com>
Subject: Re: [Security] [PATCH] infinite recursion in netlink
Date: Wed, 25 Apr 2007 22:29:12 -0700
Message-ID: <20070426052912.GA17402@kroah.com>
References: <20070425183856.GA6028@ms2.inr.ac.ru> <alpine.LFD.0.98.0704251311270.9964@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, davem@davemloft.net,
	security@kernel.org, netdev@vger.kernel.org, jaco@kroon.co.za
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:48810 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754713AbXDZF3W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 01:29:22 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.98.0704251311270.9964@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 25, 2007 at 01:15:12PM -0700, Linus Torvalds wrote:
> 
> 
> On Wed, 25 Apr 2007, Alexey Kuznetsov wrote:
> > 
> > Reply to NETLINK_FIB_LOOKUP messages were misrouted back to kernel,
> > which resulted in infinite recursion and stack overflow.

Wait, I just had the bright idea of actually testing this before I
pushed out a 2.6.20.9 kernel with another fix in it, and nope, still
crashes, even with this patch  :(

Full stackdump in a picture (forgot to have netconsole running) at:
	http://www.kroah.com/netlink_oops.jpg

Any thoughts?

I'll go try 2.6.21 now too...

thanks,

greg k-h
