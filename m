From: David Miller <davem@davemloft.net>
Subject: Re: [1/4] kevent: core files.
Date: Fri, 23 Jun 2006 13:19:40 -0700 (PDT)
Message-ID: <20060623.131940.48806210.davem@davemloft.net>
References: <20060623070933.GA20291@2ka.mipt.ru>
	<20060623184457.GA13617@kvack.org>
	<20060623192422.GA11508@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bcrl@kvack.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:10169
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1752027AbWFWUTk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 16:19:40 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060623192422.GA11508@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Fri, 23 Jun 2006 23:24:29 +0400

> Linux just does not have unified event processing mechanism, which was
> pointed to many times in AIO mail list and when epoll() was only
> introduced. I would even say, that Linux does not have such mechanism at
> all, since every potential user implements it's own, which can not be
> used with others.
> 
> Kevent fixes that. Although implementation itself can be suboptimal for
> some cases or even unacceptible at all, but it is really needed
> functionality.

I completely agree with Evgeniy here.

There is nothing in the kernel today that provides integrated event
handling.  Nothing.  So when someone says to use the "existing" stuff,
they need to have their head examined.

The existing AIO stuff stinks as a set of interfaces.  It was designed
by a standards committee, not by people truly interested in a good
performing event processing design.  It is especially poorly suited
for networking, and any networking developer understands this.

It is pretty much a foregone conclusion that we will need new
APIs to get good networking performance.  Every existing interface
has one limitation or another.

So we should be happy people like Evgeniy try to work on this stuff,
instead of discouraging them.
