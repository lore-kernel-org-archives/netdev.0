From: Simon Horman <horms@verge.net.au>
Subject: Re: [rfc 0/4] igb: bandwidth allocation
Date: Thu, 5 Nov 2009 13:21:23 +1100
Message-ID: <20091105022123.GA22019@verge.net.au>
References: <20091105005847.941190065@vergenet.net>
 <9929d2390911041746g2b5f51cdia489bd87d87e41ef@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Arnd Bergmann <arndbergmann@googlemail.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:49097 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754797AbZKECVT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 21:21:19 -0500
Content-Disposition: inline
In-Reply-To: <9929d2390911041746g2b5f51cdia489bd87d87e41ef@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 04, 2009 at 05:46:50PM -0800, Jeff Kirsher wrote:
> On Wed, Nov 4, 2009 at 16:58, Simon Horman <horms@verge.net.au> wrote:
> > Hi,
> >
> > this series of patches exposes the bandwidth allocation
> > hardware support of the Intel 82576. It does so through
> > a rather hackish sysfs entry. That interface is just intended
> > for testing so that the exposed hardware feature can
> > be exercised. I would like to find a generic way to expose
> > this feature to user-space.
> >
> 
> Thanks Simon.  I have add the 4 patch series to my tree for testing.

Thanks. I wanted to get the code out rather than sitting on it
for lack of a better user-space interface. Although there
is a lot of fluff the actual register twiddling for
bandwidth allocation turned out to be quite simple.


