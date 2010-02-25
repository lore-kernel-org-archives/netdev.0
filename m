From: "Stephens, Allan" <allan.stephens@windriver.com>
Subject: RE: [PATCH]: tipc: Fix oops on send prior to entering networked mode
Date: Thu, 25 Feb 2010 12:33:37 -0800
Message-ID: <29C1DC0826876849BDD9F1C67ABA2943070F1B89@ala-mail09.corp.ad.wrs.com>
References: <20100224185340.GB15380@hmsreliant.think-freely.org> <29C1DC0826876849BDD9F1C67ABA2943070F1534@ala-mail09.corp.ad.wrs.com> <20100224211507.GC15380@hmsreliant.think-freely.org> <20100224.173811.264809559.davem@davemloft.net> <29C1DC0826876849BDD9F1C67ABA2943070F1849@ala-mail09.corp.ad.wrs.com> <20100225152328.GA2990@shamino.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <jon.maloy@ericsson.com>,
	<tipc-discussion@lists.sourceforge.net>
To: "Neil Horman" <nhorman@tuxdriver.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:55477 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932934Ab0BYUdy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2010 15:33:54 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20100225152328.GA2990@shamino.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Neil Horman [mailto:nhorman@tuxdriver.com] 
> Sent: Thursday, February 25, 2010 10:23 AM

[text deleted]

> To me I see that and read it as:
> "We didn't have time to do things the way the Linux 
> maintainers like to have them done, so we went off and did it 
> on our own, figuring we'd get back to doing it the right way later"
> 
> Well, flash forward 1.5 years, and getting back to it never 
> happened.  While I understand that can happen, it puts users 
> in the lurch if they expect upstream to be the latest bits.  
> As such, have you considered just dropping TIPC from upstream 
> entirely?  I know that sounds a bit angry, I don't intend it 
> to, I mean it in all seriousness.  Companies have constraints 
> that sometimes conflict with upstream practices though, thats 
> just a fact of life, and theres nothing we can really do 
> about that.  But if the review/accptance criteria of upstream 
> development doesn't fit into a companies budget or schedule, 
> not doing kernel community development might be the best 
> solution.  Doing so tells the distros that they have extra 
> work to do if they want to incorporate/support tipc in their 
> kernels, and frees your company to develop on its own 
> schedule, and according to its own resources, while still 
> being accessable to end users.  Of course, in so doing you 
> don't get the maintenence changes that come with an ever 
> evolving ABI/etc, but thats the price you would have to pay, 
> and a decision you could make.
> 
> I'm not trying to tell you its the best solution, just an 
> alternate option.
> Honestly, what I'd like to see is all the remaining changes 
> in TIPC 1.7 go in as individual commits, so that we have a 
> good change history, and a resonable review on all the 
> changes.  I know that takes longer but I think its the right 
> solution.  I'll even volunteer to help, if that lightens your 
> load any.  If you can provide me access to whatever scm you 
> used (or even some modicum of changelog in a text file, so 
> that we could try to match up changes with documentation), 
> I'll happily start pulling stuff apart to get it upstream.

I can't argue with the basic thrust of your comments, Neil, nor with the
similar comments David has made in his previous emails.  The current
situation is certainly regrettable, and I think we're all in agreement
that the best solution is to get the remainder of TIPC 1.7 into Linux as
soon as possible (as individual patches, not a single mega-patch), then
to limit any future changes to the upstream side of things.

I've got no problem with Neil's offer to assist in getting the necessary
patches generated, as this will undoubtedly speed things along faster
than anything I could do on my own.  (I suggest that we get started on
this once we get the current oops situation resolved.)  This kind of
offer to share the burden is to be commended, and is an example that
other TIPC users should look to.


> But if thats a one shot deal, and you believe that the next 
> schedule crunch you have will result in your company making 
> another out-of-tree update, then perhaps switching to that 
> mode of out-of-tree development might be worth consideration.
> 
> Regards
> Neil

Actually, we've got no plans to continue doing out-of-tree development
on TIPC -- we've already suffered enough pain by following that route,
and I certainly don't want to repeat the experience!  The upside of
having done things out-of-tree in the past is that it gives us hard data
we can use to squelch discussion the next time somebody suggests doing
it again.

Regards,
Al
 
