From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/1] netlink: no need to crash if table does not exist.
Date: Wed, 28 Mar 2007 12:43:06 +0400
Message-ID: <20070328084306.GB28242@2ka.mipt.ru>
References: <20070321104456.GA2637@2ka.mipt.ru> <46010EF5.6010306@trash.net> <20070321105847.GA18221@2ka.mipt.ru> <20070327.164154.48396509.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:44843 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752674AbXC1Inh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2007 04:43:37 -0400
Content-Disposition: inline
In-Reply-To: <20070327.164154.48396509.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 27, 2007 at 04:41:54PM -0700, David Miller (davem@davemloft.net) wrote:
> > There is no problem as-is, but I implement unified cache for different
> > sockets (currently tcp/udp/raw and netlink are supported), which does
> > not use that table, so I currently wrap all access code into special
> > ifdefs, this one can be wrapped too, but since it is not needed, it
> > saves couple of lines of code.
> 
> It is needed.  It is there to make sure that a kernel netlink
> socket is not created before the af_netlink init code runs.
> 
> We've had sequencing bugs like that in the initcall call chain
> in the past, that's why the check is there.

Argh, I see.
I fail to find exact commit (at least it was not in 2.4 and was created
before 2.6.12), but it is ineed neeed.

Thanks for explaination.

-- 
	Evgeniy Polyakov
