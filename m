From: Simon Horman <horms@verge.net.au>
Subject: Re: [rfc 0/4] igb: bandwidth allocation
Date: Wed, 25 Nov 2009 17:31:09 +1100
Message-ID: <20091125063104.GC4894@verge.net.au>
References: <20091105005847.941190065@vergenet.net>
 <9929d2390911041746g2b5f51cdia489bd87d87e41ef@mail.gmail.com>
 <20091105022123.GA22019@verge.net.au>
 <9929d2390911140001t2938271ep7455de5874ee0144@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Arnd Bergmann <arndbergmann@googlemail.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:51218 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751343AbZKYGbF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 01:31:05 -0500
Content-Disposition: inline
In-Reply-To: <9929d2390911140001t2938271ep7455de5874ee0144@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 14, 2009 at 12:01:32AM -0800, Jeff Kirsher wrote:
> On Wed, Nov 4, 2009 at 18:21, Simon Horman <horms@verge.net.au> wrote=
:
> > On Wed, Nov 04, 2009 at 05:46:50PM -0800, Jeff Kirsher wrote:
> >> On Wed, Nov 4, 2009 at 16:58, Simon Horman <horms@verge.net.au> wr=
ote:
> >> > Hi,
> >> >
> >> > this series of patches exposes the bandwidth allocation
> >> > hardware support of the Intel 82576. It does so through
> >> > a rather hackish sysfs entry. That interface is just intended
> >> > for testing so that the exposed hardware feature can
> >> > be exercised. I would like to find a generic way to expose
> >> > this feature to user-space.
> >> >
> >>
> >> Thanks Simon. =C2=A0I have add the 4 patch series to my tree for t=
esting.
> >
> > Thanks. I wanted to get the code out rather than sitting on it
> > for lack of a better user-space interface. Although there
> > is a lot of fluff the actual register twiddling for
> > bandwidth allocation turned out to be quite simple.
> >
>=20
> Simon -
> After doing some testing on the series of patches, we are getting a
> panic with these patches applied to net-next.  I have provided below
> the panic we saw, right now we have a large patch load so a bisect
> will have to wait.  Hopefully with time permitting, we will be able t=
o
> revisit these patches soon.

Hi Jeff,

sorry for not getting back to you earlier, I've been caught up with
family matters for the past few weeks (my wife had a baby!).

It seems that the problem was caused by the second patch in the series
moving the initialisation of adapter->vfs_allocated_count.
I will submit a fresh patch series to resolve this and some
other minor problems.


