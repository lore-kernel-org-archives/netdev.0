From: Greg KH <greg@kroah.com>
Subject: Re: [Security] [PATCH] infinite recursion in netlink
Date: Wed, 25 Apr 2007 23:51:51 -0700
Message-ID: <20070426065151.GA4247@kroah.com>
References: <20070426054842.GA18630@kroah.com> <20070426055259.GF2819@sequoia.sous-sol.org> <20070426062601.GH2819@sequoia.sous-sol.org> <20070425.233121.41192812.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chrisw@sous-sol.org, security@kernel.org, netdev@vger.kernel.org,
	jaco@kroon.co.za, kuznet@ms2.inr.ac.ru,
	torvalds@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([209.217.80.40]:41014 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933152AbXDZGzh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 02:55:37 -0400
Content-Disposition: inline
In-Reply-To: <20070425.233121.41192812.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 25, 2007 at 11:31:21PM -0700, David Miller wrote:
> From: Chris Wright <chrisw@sous-sol.org>
> Date: Wed, 25 Apr 2007 23:26:01 -0700
> 
> > Working fine here.  Any chance you booted a stale kernel?
> > If not, what's your nl_fib_input+0xe4.  Any chance that's
> > actually in nl_fib_lookup?
> 
> I'm seriously hoping it's a stale kernel or similar,
> because I can't account for it any other way :-)

I did a 'make clean' and rebuilt 2.6.20.9 and I can't duplicate this
again.

Sorry for the false alarm, I have no idea what when wrong here.  Glad
the bug is really fixed.

Now to push 2.6.20.9 out...

again, sorry,

greg k-h
