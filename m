From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: GFP_ATOMIC page allocation failures.
Date: Thu, 3 Apr 2008 16:57:43 +1100
Message-ID: <200804031657.43895.nickpiggin@yahoo.com.au>
References: <20080401235609.GA6947@codemonkey.org.uk> <20080402103355.77ef22ff.akpm@linux-foundation.org> <47F3CE10.1060903@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Chris Snook <csnook@redhat.com>,
	Dave Jones <davej@codemonkey.org.uk>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp113.mail.mud.yahoo.com ([209.191.84.66]:27893 "HELO
	smtp113.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757366AbYDCF5u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 01:57:50 -0400
In-Reply-To: <47F3CE10.1060903@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 03 April 2008 05:18, Jeff Garzik wrote:

> Turning to Nick's comment,
>
> > It's still actually nice to know how often it is happening even for
> > these known good sites because too much can indicate a problem and
> > that you could actually bring performance up by tuning some things.
>
> then create a counter or acculuation buffer somewhere.
>
> We don't need spew every time there is memory pressure of this magnitude.

Not a complete solution. Counter would be nice, but you need backtraces
and want a way to more proactively warn the user/tester/developer.

I agree that I don't exactly like adding nowarns around, and I don't think
places like driver writers should have to know about this stuff.


> IMO there are much better ways than printk(), to inform tasks, and
> humans, of allocation failures.

I think with a tweaked warning message, a ratelimited printk is OK.
