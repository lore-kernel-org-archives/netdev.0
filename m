From: Bodo Eggert <7eggert@gmx.de>
Subject: Re: GFP_ATOMIC page allocation failures.
Date: Fri, 04 Apr 2008 11:52:34 +0200
Message-ID: <E1Jhib4-0000md-FP@be1.7eggert.dyndns.org>
References: <adYyJ-20N-11@gated-at.bofh.it> <aef6w-6rx-45@gated-at.bofh.it> <aefJ9-7KR-15@gated-at.bofh.it> <aeqF6-45P-29@gated-at.bofh.it>
Reply-To: 7eggert@gmx.de
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7Bit
To: Nick Piggin <nickpiggin@yahoo.com.au>,
	Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Chris Snook <csnook@redhat.com>,
	Dave Jones <davej@codemonkey.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.183]:64832 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752756AbYDDJxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2008 05:53:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> On Thursday 03 April 2008 05:18, Jeff Garzik wrote:

>> Turning to Nick's comment,
>>
>> > It's still actually nice to know how often it is happening even for
>> > these known good sites because too much can indicate a problem and
>> > that you could actually bring performance up by tuning some things.
>>
>> then create a counter or acculuation buffer somewhere.
>>
>> We don't need spew every time there is memory pressure of this magnitude.
> 
> Not a complete solution. Counter would be nice, but you need backtraces
> and want a way to more proactively warn the user/tester/developer.
> 
> I agree that I don't exactly like adding nowarns around, and I don't think
> places like driver writers should have to know about this stuff.

What about reverse ratelimiting: If the limit is reached, a backtrace will be
generated (and, off cause, positively ratelimited)?

