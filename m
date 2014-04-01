From: Richard Guy Briggs <rgb@redhat.com>
Subject: Re: [PATCH 0/3] netlink: per-protocol bind fixup/enhancement set
Date: Tue, 1 Apr 2014 18:12:15 -0400
Message-ID: <20140401221215.GC21711@madcap2.tricolour.ca>
References: <20140324183406.GE28666@madcap2.tricolour.ca>
 <cover.1396317747.git.rgb@redhat.com>
 <20140401.173354.1207821556865053650.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-audit@redhat.com, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	eparis@redhat.com, sgrubb@redhat.com, hadi@mojatatu.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140401.173354.1207821556865053650.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 14/04/01, David Miller wrote:
> From: Richard Guy Briggs <rgb@redhat.com>
> Date: Tue,  1 Apr 2014 10:14:55 -0400
> 
> > This set provides a way for per-protocol bind functions to signal an error and
> > to be able to clean up after themselves.
> > 
> > The first patch has already been accepted, but is included just in case to
> > avoid a merge error.
> > 
> > The second patch adds the per-protocol bind return code to signal to the
> > netlink code that no further processing should be done and to undo the work
> > already done.  This rev has fixed DaveM's last issue and flattened the
> > intentation as requested by Patrick McHardy by two by reworking the logic.
> > 
> > The third provides a way per protocol to undo actions on DROP.
> > 
> > Thanks for the feedback.
> 
> I would like to defer this to the next merge window.

I was hoping to get it into this merge window, but but I agree it is a
bit late for that.  If I had succeeded in posting it to the correct list
address back in February it wouldn't be late.

> I'd also like to see how the AUDIT code is going to use this, provide
> the user in your next submission.

That context was already posted here:
	https://www.redhat.com/archives/linux-audit/2014-February/msg00102.html
	https://lkml.org/lkml/2014/2/19/481

I discovered later I used a stale list address for netdev and didn't Cc
you directly, so you likely would have missed it.

> Right now the only user is nfnetlink and it's merely to do a
> (sub-)module request.
> 
> Therefore it's no surprise that we've never had any real well thought
> out semantics defined for the bind method, and it's also why we never
> thought of adding an unbind method before.

No problem.  It was recommended I resend patch 3/5 of that set,
isolated, to get it reviewed here.  These recent changes to that patch
should not affect patches 1, 2, 4, 5 of that original patch context.

Does that help?

- RGB

--
Richard Guy Briggs <rbriggs@redhat.com>
Senior Software Engineer, Kernel Security, AMER ENG Base Operating Systems, Red Hat
Remote, Ottawa, Canada
Voice: +1.647.777.2635, Internal: (81) 32635, Alt: +1.613.693.0684x3545
