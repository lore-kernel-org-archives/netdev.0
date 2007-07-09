From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [Cbe-oss-dev] [PATCH] ps3: gigabit ethernet driver for PS3, take3
Date: Mon, 9 Jul 2007 13:53:27 -0500
Message-ID: <20070709185327.GI4457@austin.ibm.com>
References: <468D2098.50507@austin.ibm.com> <20070706180241.GB4457@austin.ibm.com> <20070709102243.03C0.AKIRAT@rd.scei.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Masakazu Mokuno <mokuno@sm.sony.co.jp>, netdev@vger.kernel.org,
	Jeff Garzik <jeff@garzik.org>, cbe-oss-dev@ozlabs.org
To: Akira Tsukamoto <akirat@rd.scei.sony.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:52704 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760146AbXGISxj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 14:53:39 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l69IrXQP018088
	for <netdev@vger.kernel.org>; Mon, 9 Jul 2007 14:53:33 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l69IrV0i265254
	for <netdev@vger.kernel.org>; Mon, 9 Jul 2007 12:53:32 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l69IrRsZ015935
	for <netdev@vger.kernel.org>; Mon, 9 Jul 2007 12:53:28 -0600
Content-Disposition: inline
In-Reply-To: <20070709102243.03C0.AKIRAT@rd.scei.sony.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 09, 2007 at 10:50:19AM +0900, Akira Tsukamoto wrote:
> Hi,
> 
> On Fri, 6 Jul 2007 13:02:41 -0500, linas@austin.ibm.com (Linas Vepstas) mentioned: 
> > of the spidernet device driver.  Please note that the old
> > spidernet had absolutely disasterous performance for transmit;
> > it also had a variety of crazy hangs and lockups under 
> > high-stress conditions; or NFS operation, or certain back-to-back
> > tcp usage scenarios. A few dozen bugfixes went in since
> > the time that the gelic snapshot was taken.
> 
> I think we know the problems of old spidernet issues, we uses QS20 also 
> in our lab.
> Current gelic has fixed them all separated from your work and it have no 
> remaining issues or performance problem.
> In our measurement, PS3 network performance is better than IBM QS20 right
> now.

!! Well, gee, I wish this plan had been made public. I'd spent something
between 3-6 months working full-time on spidernet issues. This was a lot
of work and effort.  Worse, this was *not* my main job; it was rather to 
help the neighbors prevent a disaster in the making.  Certainly, I would 
not have spent any time on this, if I'd known someone else was also working 
to fix the same bugs. :-(

> I totally understand difficultness of your effort that fixing spidernet 
> without decent documentation which we have, but the changes we made was 
> significantly large as you see if you diff gelic driver with current 
> spidernet driver (totally different), 

The differences are very large, because very large changes have been made
to the spidernet. However, a diff between gelic and the old spidernet is
much smaller.  So I'm somewhat confused by this.  Perhaps I am mistaken, 
and should read the code more carefully.

> so the conclusion of discussion at 
> 3C common-linux wg (Sony, IBM and Toshiba) 

?? What working group is this?  This is the first time that I am hearing
of it, and, as the only active spidernet maintainer, I'd hope to have
been a part of suc discussion. Oh well.

-- Linas Vepstas
