From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH 1/2] ipaddress: Simplify vf_info parsing
Date: Fri, 1 Jul 2016 19:50:01 +0200
Message-ID: <20160701175001.GG19370@orbyte.nwl.cc>
References: <1464811430-19415-1-git-send-email-phil@nwl.cc>
 <1464811430-19415-2-git-send-email-phil@nwl.cc>
 <CALgkqUq5nedx+wjEur9WVjvYr0pzvL7CMQmHiVtuuB_1PtOZ2Q@mail.gmail.com>
 <20160601220750.GC2729@orbyte.nwl.cc>
 <CALgkqUq8uDErRPMxyDx-M5UQB3v5+tHMyxXpAmK381W_z9KXPg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemming@brocade.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Greg Rose <gvrose8192@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:56739 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751680AbcGARuE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jul 2016 13:50:04 -0400
Content-Disposition: inline
In-Reply-To: <CALgkqUq8uDErRPMxyDx-M5UQB3v5+tHMyxXpAmK381W_z9KXPg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 01, 2016 at 03:36:09PM -0700, Greg Rose wrote:
> On Wed, Jun 1, 2016 at 3:07 PM, Phil Sutter <phil@nwl.cc> wrote:
> > On Wed, Jun 01, 2016 at 03:00:08PM -0700, Greg Rose wrote:
> >> On Wed, Jun 1, 2016 at 1:03 PM, Phil Sutter <phil@nwl.cc> wrote:
> >> > Not sure whether I misinterpret commit 7b8179c780a1a, but it looks
> >> > overly complicated. Instead rely upon parse_rtattr_nested() to assign
> >> > the relevant pointer if requested rtattr fields are present.
> >>
> >> I'm not sure if newer iproute2 utilities are supposed to work on older
> >> kernels but if it is you may want to check this against a 2.6.32
> >> kernel.
> >
> > Yes, it is supposed to. Actually I tried, but the old RHEL6 kernel I
> > used didn't export the VF list at all and then I lost motivation.
> >
> > I didn't check all earlier versions of 7b8179c780a1a, was there a stage
> > when it looked like what I'm changing it to?
> 
> I don't think so but your patch looks correct - I mean it looks like
> it should work.
> 
> It's been 5 years since I wrote that original patch and my memory
> isn't so great as to why I didn't just do as your patch does but I
> think it had something to do with not all drivers reporting a spoof
> check value.  However, your patch should handle that case so I see no
> reason not to accept it.  Unfortunately I don't have time or the
> resources at the moment to check it on an older kernel.

So can I count that as your Acked-by? ;)
Looks like Stephen hesitates to accept this patch due to the discussion
it provoked.

Cheers, Phil
