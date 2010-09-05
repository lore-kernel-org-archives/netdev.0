From: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/2] [RFC] posix clock tuning
Date: Sat, 4 Sep 2010 20:47:39 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1009042042130.9425@router.home>
References: <cover.1283504065.git.richard.cochran@omicron.at> <alpine.DEB.2.00.1009041221240.888@router.home> <4C828652.4060804@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Christian Riesch <christian.riesch-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4C828652.4060804-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 4 Sep 2010, Christian Riesch wrote:

> Richard's idea is to support clock hardware for IEEE 1588 (PTP, Precision Time
> Protocol). Have a look at the earlier discussions:
>
> http://lkml.org/lkml/2010/8/16/90

A superficial scan does not give me any definite agreement on an approach.
The patchset also needs to be CCed to John Stultz. Without a summary I
still am not clear what this is supposed to address.

Tuning of the PTP clock can be done with driver specific configuration
rather than a new POSIX clock. That is at least how SGI_CYCLE is operating
which is similar.

> http://lkml.org/lkml/2010/8/23/49

Ok this goes more into something that may prove useful but it would be
very helpful still to have a clear discussion as to why this is all
needed. From what I can tell the functionality is already there and
another clock device (CLOCK_SGI_CYCLE) is already providing a model for
how a PTP clock could be controlled and used.
