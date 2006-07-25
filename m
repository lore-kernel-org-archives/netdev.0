From: Nicholas Miell <nmiell@comcast.net>
Subject: Re: async network I/O, event channels, etc
Date: Tue, 25 Jul 2006 15:55:10 -0700
Message-ID: <1153868110.2661.10.camel@entropy>
References: <44C66FC9.3050402@redhat.com>
	 <20060725.150122.49854414.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: drepper@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sccrmhc11.comcast.net ([63.240.77.81]:52368 "EHLO
	sccrmhc11.comcast.net") by vger.kernel.org with ESMTP
	id S1030220AbWGYWzN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jul 2006 18:55:13 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060725.150122.49854414.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-07-25 at 15:01 -0700, David Miller wrote:
> From: Ulrich Drepper <drepper@redhat.com>
> Date: Tue, 25 Jul 2006 12:23:53 -0700
> 
> > I was very much surprised by the reactions I got after my OLS talk.
> > Lots of people declared interest and even agreed with the approach and
> > asked me to do further ahead with all this.  For those who missed it,
> > the paper and the slides are available on my home page:
> > 
> > http://people.redhat.com/drepper/
> > 
> > As for the next steps I see a number of possible ways.  The discussions
> > can be held on the usual mailing lists (i.e., lkml and netdev) but due
> > to the raw nature of the current proposal I would imagine that would be
> > mainly perceived as noise.
> 
> Since I gave a big thumbs up for Evgivny's kevent work yesterday
> on linux-kernel, you might want to start by comparing your work
> to his.  Because his has the advantage that 1) we have code now
> and 2) he has written many test applications and performed many
> benchmarks against his code which has flushed out most of the
> major implementation issues.
> 
> I think most of the people who have encouraged your work are unaware
> of Evgivny's kevent stuff, which is extremely unfortunate, the two
> works are more similar than they are different.
> 
> I do not think discussing all of this on netdev would be perceived
> as noise. :)

While the comparing is going on, how does this compare to Solaris's
ports interface? It's documented at
http://docs.sun.com/app/docs/doc/816-5168/6mbb3hrir?a=view

Also, since we're on the subject, why a whole new interface for event
queuing instead of extending the existing io_getevents(2) and friends?

-- 
Nicholas Miell <nmiell@comcast.net>

