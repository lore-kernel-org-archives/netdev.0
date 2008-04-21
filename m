From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [bug] build failure in net/netfilter/nf_conntrack_sip.c, on	latest
 -git
Date: Mon, 21 Apr 2008 04:14:32 -0400
Message-ID: <480C4CE8.6020202@garzik.org>
References: <20080419100034.GA9475@elte.hu> <20080419.030337.244502148.davem@davemloft.net> <20080419103942.GA13599@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	kaber@trash.net, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, NetDev <netdev@vger.kernel.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56119 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753456AbYDUIOg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2008 04:14:36 -0400
In-Reply-To: <20080419103942.GA13599@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar wrote:
> * David Miller <davem@davemloft.net> wrote:
> 
>> From: Ingo Molnar <mingo@elte.hu>
>> Date: Sat, 19 Apr 2008 12:00:35 +0200
>>
>>> btw., i found no thread to reply to on lkml or elsewhere - arent all 
>>> git pull requests supposed to be Cc:-ed to lkml, with shortlog 
>>> included?
>> I have never once done this even going all the way back to the BK 
>> days.
> 
> do you find this practice of private pull requests important? If not, 
> would it be difficult to Cc: lkml to routine pull requests?
> 
>> I always send my pull requests directly to Linus, CC:'ing Andrew.
> 
> that makes bugs harder to report and makes the flow of patches harder to 
> follow as well. Often (like in this case) i see it when a bug comes in 
> via a specific group of commits but i have no time to do a bisection. In 
> that case i'd like to report it to that pull request so i'd like to 
> reply to that pull on lkml.
> 
> But in this case i first did an unsuccessful full-text search on lkml, 
> then i also opened up netdev and did a full text search there too to 
> find the originator pull request or the patches but the search turned up 
> nothing. As the number of subsystems increases, i suspect you agree with 
> me that this does not scale very well for bug reporters, correct?

Well, 'git log [$file]' is even more scalable and precise, if committer 
(as well as author) info and patch flow info is what a tester or bug 
reporter seeks.

But it sounds like you are making an assumption about development 
/style/, then complaining when reality doesn't match that assumption.


> i'm convinced that testers and bug reporters are the scarce resource 
> these days, not patch integrators and not maintainers which was the 
> scarce resource 3-4 years ago, before Git and before BK. It is testing 
> (and review) capacity that limits the growth of Linux today, not patch 
> writing and patch integration capacity.

We're all for more bug reports and testing, but the link you are trying 
to draw is more than a little overblown.  I'm not convinced LKML's lack 
of davem pull request visibility is a problem source limiting the growth 
of Linux today...  That's a bit much.  :)

AFAICT you and davem have different development styles, he doesn't work 
the way you work, but the tone of your emails recently has been "if you 
do not fit my preferred development worldview, you are creating problems 
for Linux."  Witness not just this thread, but the LKML-vs-netdev 
discussions.

	Jeff


