From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: strange tcp behavior
Date: Sat, 4 Aug 2007 20:51:51 +0400
Message-ID: <20070804165151.GE14175@2ka.mipt.ru>
References: <20070802184840.GA8901@2ka.mipt.ru> <20070802.192134.107254907.davem@davemloft.net> <20070803082242.GA25582@2ka.mipt.ru> <20070803.141717.36925406.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: simon@fire.lp0.eu, john@screen.lv, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:43619 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764126AbXHDQwI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Aug 2007 12:52:08 -0400
Content-Disposition: inline
In-Reply-To: <20070803.141717.36925406.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 03, 2007 at 02:17:17PM -0700, David Miller (davem@davemloft.net) wrote:
> From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Date: Fri, 3 Aug 2007 12:22:42 +0400
> 
> > Maybe recvmsg should be changed too for symmetry?
> 
> I took a look at this, and it's not %100 trivial.
> 
> Let's do this later, and only sendmsg for now in order to
> fix the bug in the stable branches.

I've tested your patch, besides there was an offset in one of hooks, 
it works perfectly ok.

Feel free to add my ack, tested-by or whatever is needed for this :)
Your patch fixes the problem.

Actually inet_sendmsg() can be renamed to something less misleading,
since it is not used by TCP now.

-- 
	Evgeniy Polyakov
