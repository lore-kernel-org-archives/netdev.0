From: Anand Kumria <wildfire@progsoc.uts.edu.au>
Subject: Re: RFC3927 ARP patch status?
Date: Sat, 3 Jun 2006 12:50:02 +1000
Message-ID: <20060603025001.GK549@progsoc.uts.edu.au>
References: <44806926.1050509@avtrex.com> <E1FmIoI-0007nK-00@gondolin.me.apana.org.au> <20060603003955.GJ549@progsoc.uts.edu.au> <4480DEB3.2060806@avtrex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from incubus.progsoc.uts.edu.au ([138.25.6.7]:43481 "EHLO
	incubus.progsoc.uts.edu.au") by vger.kernel.org with ESMTP
	id S1751095AbWFCCuI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jun 2006 22:50:08 -0400
To: David Daney <ddaney@avtrex.com>
Content-Disposition: inline
In-Reply-To: <4480DEB3.2060806@avtrex.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 02, 2006 at 05:58:27PM -0700, David Daney wrote:
> Anand Kumria wrote:
> >Herbert,
> >
> >On Sat, Jun 03, 2006 at 09:12:06AM +1000, Herbert Xu wrote:
> >
> >>David Daney <ddaney@avtrex.com> wrote:
> >>
> >>>There were some discussions about whether it made sense for the kernel 
> >>>to support the behavior required by the RFC.  Other comments debated the 
> >>>wisdom of using a tightly targeted patch specific to the RFC, or whether 
> >>>a more general but intrusive solution would be better.
> >>
> >>I think we've made it quite clear what needs to be done for it to be
> >>accepted.  All that remains is for someone to implement it.  If anyone
> >>really cares about this, then please write the code instead of talking
> >>about it.
> >
> >
> >Okay, to confirm: you want a patch which looks at the scope value and if 
> >the scope is link-local then we broadcast rather than do a directed ARP?
> >
> 
> I don't think that was the plan.  In an earlier e-mail Herbert Xu said 
> (and I concur):
> 
> ------------------------------
> I like the idea of allowing user-space to control what addresses cause
> broadcasts.  However, I'm uncomfortable with overloading existing flags
> even though they might appear to fit the bill on the face of it.
> 

[...]

Sorry, I can't find any email with any of those words in it by Herbert.
Could you tell me the message-id, so I can read some of the surrounding
context?

> 
> The idea was to add a new flag, *not* reuse the scope value.
> 

I guess it would be something set during RTM_NEWADDR (and returned by
RTM_GETADDR?). How does IFA_DIRECTEDARP sound? With a value type of int;
defaulting to 1.  When set to 0, generate a broadcast ARP for the
address.

Thanks,
Anand

-- 
 `When any government, or any church for that matter, undertakes to say to
  its subjects, "This you may not read, this you must not see, this you are
  forbidden to know," the end result is tyranny and oppression no matter how
  holy the motives' -- Robert A Heinlein, "If this goes on --"
