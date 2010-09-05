From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/2] [RFC] posix clock tuning
Date: Sun, 5 Sep 2010 08:22:40 +0200
Message-ID: <20100905062240.GB2699@riccoc20.at.omicron.at>
References: <cover.1283504065.git.richard.cochran@omicron.at>
 <alpine.DEB.2.00.1009041221240.888@router.home>
 <4C828652.4060804@gmail.com>
 <alpine.DEB.2.00.1009042042130.9425@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christian Riesch <christian.riesch-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1009042042130.9425-sBS69tsa9Uj/9pzu0YdTqQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 04, 2010 at 08:47:39PM -0500, Christoph Lameter wrote:
> On Sat, 4 Sep 2010, Christian Riesch wrote:
> 
> > Richard's idea is to support clock hardware for IEEE 1588 (PTP, Precision Time
> > Protocol). Have a look at the earlier discussions:
> >
> > http://lkml.org/lkml/2010/8/16/90
> 
> A superficial scan does not give me any definite agreement on an approach.

Welcome to the club. I am also not too sure how to bring everything
that was said together.

I have attempted to synthesize the various ideas from the previous
threads into a concrete form (a new patch set) in order to see:

1. If I understood what the commentators were asking for.
2. Whether people now agree on the approach.

> Ok this goes more into something that may prove useful but it would be
> very helpful still to have a clear discussion as to why this is all
> needed. From what I can tell the functionality is already there and
> another clock device (CLOCK_SGI_CYCLE) is already providing a model for
> how a PTP clock could be controlled and used.

John Stultz warned against that approach in his mail from August 18.

    http://lkml.org/lkml/2010/8/18/264

At this point, I think it is clear that, in order to support IEEE
1588, some kind of changes are needed. I have argued and discussed the
issues at some length. I am willing to continue the discussion, but I
would also appreciate more than a "superficial scan." PTP is quite a
large topic that probably cannot be adequately treated in a single
email.

Having said that, if you are convinced that the existing interfaces
are good enough to support PTP (and possible future methods, as
discussed in the threads), then I am all ears to find out how to do
make it work.

Thanks,
Richard
