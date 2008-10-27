From: David Miller <davem@davemloft.net>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Sun, 26 Oct 2008 19:34:51 -0700 (PDT)
Message-ID: <20081026.193451.36032548.davem@davemloft.net>
References: <20081026092722.GA24799@ioremap.net>
	<20081026023439.c6cf4e94.akpm@linux-foundation.org>
	<20081026100555.GA26033@ioremap.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, a.p.zijlstra@chello.nl, efault@gmx.de,
	jkosina@suse.cz, rjw@sisk.pl, mingo@elte.hu,
	s0mbre@tservice.net.ru, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: zbr@ioremap.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40451
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751294AbYJ0CfO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2008 22:35:14 -0400
In-Reply-To: <20081026100555.GA26033@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Evgeniy Polyakov <zbr@ioremap.net>
Date: Sun, 26 Oct 2008 13:05:55 +0300

> I'm not surprised there were no changes when I reported hrtimers to be
> the main guilty factor in my setup for dbench tests, and only when David
> showed that they also killed his sparks via wake_up(), something was
> done. Now this regression even dissapeared from the list.
> Good direction, we should always follow this.

Yes, this situation was in my opinion a complete fucking joke.  Someone
like me shouldn't have to do all of the hard work for the scheduler
folks in order for a bug like this to get seriously looked at.

Evgeniy's difficult work was effectively ignored except by other
testers who could also see and reproduce the problem.

No scheduler developer looked seriously into these reports other than
to say "please try to reproduce with tip" (?!?!?!)  I guess showing
the developer the exact changeset(s) which add the regression isn't
enough these days :-/

Did any scheduler developer try to run tbench ONCE and do even a tiny
bit of analysis, like the kind I did?  Answer honestly...  Linus even
asked you guys in the private thread to "please look into it".  So, if
none of you did, you should all be deeply ashamed of yourselves.

People like me shouldn't have to do all of that work for you just to
get something to happen.

Not until I went privately to Ingo and Linus with cycle counts and a
full disagnosis (of every single release since 2.6.22, a whole 2 days
of work for me) of the precise code eating up too many cycles and
causing problems DID ANYTHING HAPPEN.

This is extremely and excruciatingly DISAPPOINTING and WRONG.

We completely and absolutely suck if this is how we will handle any
performance regression report.

And although this case is specific to the scheduler, a lot of
other areas handle well prepared bug reports similarly.  So I'm not
really picking on the scheduler folks, they just happen to be the
current example :-)

