From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: Allowing more than 64k connections and heavily optimize bind(0) time.
Date: Sun, 11 Jan 2009 15:03:10 +0200
Message-ID: <200901111503.10736.denys@visp.net.lb>
References: <20081224190926.GA3244@ioremap.net> <20090110.232019.98466627.davem@davemloft.net> <20090111125206.GA24173@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:60573 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751233AbZAKNDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 08:03:30 -0500
In-Reply-To: <20090111125206.GA24173@ioremap.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I did test on loaded squid.

49878 connections established ,1421/sec
It is not peak time yet, passed 24 hours testing.

I can't compare load, because it is real life load and always vary, but thing 
i can say, it doesn't crash :-)

On Sunday 11 January 2009 14:52:06 Evgeniy Polyakov wrote:
> On Sat, Jan 10, 2009 at 11:20:19PM -0800, David Miller (davem@davemloft.net) 
wrote:
> > > I'm getting out from the vacations tomorrow and will try to more
> > > extensively test the patch (QA group found a bug in ipv6 side, but that
> > > was with the .24 backported patch, current one does not have that
> > > codepath iirc). But I would like to know if this worth it.
> >
> > I'll look at it at some point but it won't make this merge window,
> > sorry.
>
> Ok, please drop me a not and if things are good, merge the patch
> into the appropriate tree for the next window when time permits.


