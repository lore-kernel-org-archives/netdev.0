From: Anand Kumria <wildfire@progsoc.uts.edu.au>
Subject: Re: RFC3927 ARP patch status?
Date: Sat, 3 Jun 2006 10:39:55 +1000
Message-ID: <20060603003955.GJ549@progsoc.uts.edu.au>
References: <44806926.1050509@avtrex.com> <E1FmIoI-0007nK-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Daney <ddaney@avtrex.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from incubus.progsoc.uts.edu.au ([138.25.6.7]:43726 "EHLO
	incubus.progsoc.uts.edu.au") by vger.kernel.org with ESMTP
	id S932589AbWFCAkD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jun 2006 20:40:03 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1FmIoI-0007nK-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert,

On Sat, Jun 03, 2006 at 09:12:06AM +1000, Herbert Xu wrote:
> David Daney <ddaney@avtrex.com> wrote:
> > 
> > There were some discussions about whether it made sense for the kernel 
> > to support the behavior required by the RFC.  Other comments debated the 
> > wisdom of using a tightly targeted patch specific to the RFC, or whether 
> > a more general but intrusive solution would be better.
> 
> I think we've made it quite clear what needs to be done for it to be
> accepted.  All that remains is for someone to implement it.  If anyone
> really cares about this, then please write the code instead of talking
> about it.

Okay, to confirm: you want a patch which looks at the scope value and if 
the scope is link-local then we broadcast rather than do a directed ARP?

One I have where IPv6 encodes what address mask is link-local,
I'd like to follow the same style as. Should the kernel also set the
scope on IPv4 addresses like it does for IPv6 ones?

Thanks,
Anand

-- 
 `When any government, or any church for that matter, undertakes to say to
  its subjects, "This you may not read, this you must not see, this you are
  forbidden to know," the end result is tyranny and oppression no matter how
  holy the motives' -- Robert A Heinlein, "If this goes on --"
