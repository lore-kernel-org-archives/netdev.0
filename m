From: Ingo Molnar <mingo@elte.hu>
Subject: about bisections (was: Re: 2.6.25-rc8: FTP transfer errors)
Date: Tue, 15 Apr 2008 23:53:06 +0200
Message-ID: <20080415215306.GA7437@elte.hu>
References: <47FEADCB.7070104@rtr.ca> <20080410.172453.44434205.davem@davemloft.net> <47FEB062.3020003@rtr.ca> <20080410.173911.179180620.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lkml@rtr.ca, jesper.juhl@gmail.com, tilman@imap.cc,
	yoshfuji@linux-ipv6.org, jeff@garzik.org, rjw@sisk.pl,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	corbet@lwn.net, Linus Torvalds <torvalds@linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:51500 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932660AbYDOVxr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 17:53:47 -0400
Content-Disposition: inline
In-Reply-To: <20080410.173911.179180620.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* David Miller <davem@davemloft.net> wrote:

> And it's a win-win situation.  The incentive for a capable user to do 
> a bisect or whatever else is that if they do it their bug gets fixed 
> quickly.  That is the free market economy of Linux kernel bug 
> reporting.
> 
> It addresses the issue that in reality we'll never fix all bugs, and 
> therefore we prioritize.  And therefore if there is a bisected bug 
> report and also another one from a user who refuses to do that, guess 
> which bug gets worked on with a higher priority and which bug gets 
> fixed first?

this argument is a fallacy because it assumes that the Linux kernel is a 
closed ecosystem and i'm really surprised to see you advance this 
economic argument.

i remind you: Linux is very much not a closed ecosystem.

... and hence, your "free market economy of bugs" that in essence 
strongly suggests users to do bisections when they find bugs in 
networking, works exactly the way you did not intend it to work: it 
pushes users towards other OSs.

It pushes them towards Solaris, FreeBSD, MacOS and even Windows. That 
happens because the barrier to getting bugs fixed is _increased_ - and 
users might find it easier to participate in the ecosystem of other OSs 
- instead of having to compete with "each other" for the attention of 
the head honcho (you).

You have a unique position within Linux: through a decade of hard and 
excellent work you have built a quasi-monopoly to all things networking 
commits: if you say about something that it should go into networking it 
will, if you say that it should stay out, it wont go in.

So it is fundamentally _you_ who determines the feature/fix ratio in the 
networking code, and it is _you_ who determines the amount of bugs users 
have to find! There's no real competition for your position - it would 
take years for anyone to replace you. (and it would be a shame and a 
loss - you do your job so well)

No doubt about it: bisection is very nice, it's one of the best things 
that happened to Linux debuggability in the past 2 years, i use it 
heavily myself, but please do _not_ require it from testers and users. 
They dont have nice 32-way Niagara's to build a kernel in 1 minute. They 
dont have nice virtualization to do easy bisection. Take bisection as an 
additional gift/tool but dont make it a semi-required aspect of your 
subsystem. Pretty please.

And _PLEASE_ realize that the networking bug-count has been created 
primarily by _you_, because it is you who throttles the amount of new 
code in new kernel releases. If you cannot cope with the resulting 
bug-count via your network of users - it might be perhaps because you 
let too much new stuff in to begin with?

	Ingo
