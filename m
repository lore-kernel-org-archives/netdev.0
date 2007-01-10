From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [take32 0/10] kevent: Generic event handling mechanism.
Date: Wed, 10 Jan 2007 06:56:40 -0500
Message-ID: <45A4D478.2030200@garzik.org>
References: <11684170003907@2ka.mipt.ru> <45A4C9DE.8020605@garzik.org> <20070110113051.GA4950@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Jamal Hadi Salim <hadi@cyberus.ca>,
	Ingo Molnar <mingo@elte.hu>, linux-fsdevel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42652 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932754AbXAJL46 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jan 2007 06:56:58 -0500
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20070110113051.GA4950@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> On Wed, Jan 10, 2007 at 06:11:26AM -0500, Jeff Garzik (jeff@garzik.org) wrote:
>> Once the rate of change slows, Andrew should IMO definitely pick this up.
> 
> There are _tons_ of ideas to implement with kevent - so if we want, rate
> will not slow down. As you can see, from take26 I only send new
> features: signals, posix timers, AIO, userspace notifications, various
> flags and the like. I test it on my machines (recently one them died, so
> only amd64 right now (running kernel) and i386 compile-only)
> and some bug-fixes withoout any additioanl feature requests (almost,
> Ingo asked for AIO before New Year), but broader testing is welcome
> indeed.

If the rate doesn't slow (if only artificially), people are discouraged 
from reviewing, because it becomes a moving target.


>> If you wanted to make this process automatic, create a git branch that 
>> Andrew and others can pull.
> 
> Exported git tree would be good, but I do not have enough disk space on

Request an account on http://www.foo-projects.org/ which supports git. 
The Intel guys use it to send me e1000/ixgb changes, for example.


> web-site, and do you really want to read comments written in bad english
> with russian transliterated indecent words?

The only thing exported to -mm is the code changes, as a patch.  git 
merely automates the process, so that Andrew doesn't have to spend time 
[that he doesn't have] tracking a project with a high rate of change.


>> I like the direction so far, and think it should be in -mm for wider 
>> testing and review.
> 
> It was there, but Andrew dropped it somewhere about take25 :)

Probably because it was a moving target with a high rate of change, 
requiring time that Andrew did not have just to keep in sync and fix 
build conflicts with other -mm patches.

	Jeff


