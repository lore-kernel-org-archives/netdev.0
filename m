From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: Re: [PATCH] net: Limit socket I/O iovec total length to INT_MAX.
Date: Fri, 29 Oct 2010 16:22:49 -0400
Message-ID: <1288383769.2092.62.camel@dan>
References: <AANLkTi=sUDRzGnkp57OCQUi9APHWLYLShhiTVHLyq1eV@mail.gmail.com>
	 <20101029.123230.226768623.davem@davemloft.net>
	 <AANLkTikGkfcHdemZwURrYLPBC1QQnbQP_g-7YadzeE-D@mail.gmail.com>
	 <20101029.125509.104071725.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, viro@zeniv.linux.org.uk,
	netdev@vger.kernel.org, jon.maloy@ericsson.com,
	allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:56011 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757635Ab0J2UWz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 16:22:55 -0400
In-Reply-To: <20101029.125509.104071725.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for your work on this.  Just a friendly reminder not to forget
the compat code.  :)

-Dan

On Fri, 2010-10-29 at 12:55 -0700, David Miller wrote:
> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Fri, 29 Oct 2010 12:37:29 -0700
> 
> > On Fri, Oct 29, 2010 at 12:32 PM, David Miller <davem@davemloft.net> wrote:
> >>
> >> I just got out of a long dentist appointment, will look at this right
> >> now, thanks!
> > 
> > I booted with it and committed it as "obvious". Let's see if there is
> > any fallout. I doubt it, but I also doubt we'll find any until we have
> > lots of testers, unless I made some subtly totally buggy change that
> > just didn't happen to show up during a normal boot.
> 
> It ought to be ok.
> 
> Let me send you a pull request so you can get the verify_iovec() change.


