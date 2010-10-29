From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Limit socket I/O iovec total length to INT_MAX.
Date: Fri, 29 Oct 2010 12:55:09 -0700 (PDT)
Message-ID: <20101029.125509.104071725.davem@davemloft.net>
References: <AANLkTi=sUDRzGnkp57OCQUi9APHWLYLShhiTVHLyq1eV@mail.gmail.com>
	<20101029.123230.226768623.davem@davemloft.net>
	<AANLkTikGkfcHdemZwURrYLPBC1QQnbQP_g-7YadzeE-D@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: viro@zeniv.linux.org.uk, netdev@vger.kernel.org,
	jon.maloy@ericsson.com, allan.stephens@windriver.com,
	drosenberg@vsecurity.com
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39190
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759156Ab0J2Tyq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 15:54:46 -0400
In-Reply-To: <AANLkTikGkfcHdemZwURrYLPBC1QQnbQP_g-7YadzeE-D@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 29 Oct 2010 12:37:29 -0700

> On Fri, Oct 29, 2010 at 12:32 PM, David Miller <davem@davemloft.net> wrote:
>>
>> I just got out of a long dentist appointment, will look at this right
>> now, thanks!
> 
> I booted with it and committed it as "obvious". Let's see if there is
> any fallout. I doubt it, but I also doubt we'll find any until we have
> lots of testers, unless I made some subtly totally buggy change that
> just didn't happen to show up during a normal boot.

It ought to be ok.

Let me send you a pull request so you can get the verify_iovec() change.
