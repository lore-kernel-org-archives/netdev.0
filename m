From: David Miller <davem@davemloft.net>
Subject: Re: async network I/O, event channels, etc
Date: Tue, 25 Jul 2006 15:01:22 -0700 (PDT)
Message-ID: <20060725.150122.49854414.davem@davemloft.net>
References: <44C66FC9.3050402@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:22993
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030208AbWGYWBJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jul 2006 18:01:09 -0400
To: drepper@redhat.com
In-Reply-To: <44C66FC9.3050402@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ulrich Drepper <drepper@redhat.com>
Date: Tue, 25 Jul 2006 12:23:53 -0700

> I was very much surprised by the reactions I got after my OLS talk.
> Lots of people declared interest and even agreed with the approach and
> asked me to do further ahead with all this.  For those who missed it,
> the paper and the slides are available on my home page:
> 
> http://people.redhat.com/drepper/
> 
> As for the next steps I see a number of possible ways.  The discussions
> can be held on the usual mailing lists (i.e., lkml and netdev) but due
> to the raw nature of the current proposal I would imagine that would be
> mainly perceived as noise.

Since I gave a big thumbs up for Evgivny's kevent work yesterday
on linux-kernel, you might want to start by comparing your work
to his.  Because his has the advantage that 1) we have code now
and 2) he has written many test applications and performed many
benchmarks against his code which has flushed out most of the
major implementation issues.

I think most of the people who have encouraged your work are unaware
of Evgivny's kevent stuff, which is extremely unfortunate, the two
works are more similar than they are different.

I do not think discussing all of this on netdev would be perceived
as noise. :)


