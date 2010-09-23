From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [Bugme-new] [Bug 18592] New: Remote/local Denial of
 Service vulnerability in SCTP packet/chunk handling
Date: Thu, 23 Sep 2010 11:05:15 -0700
Message-ID: <20100923180515.GG23040@kroah.com>
References: <bug-18592-10286@https.bugzilla.kernel.org/>
 <20100915124340.5bf89d07.akpm@linux-foundation.org>
 <4C916615.4060400@hp.com>
 <201009181611.05665.dreibh@iem.uni-due.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	Martin Becke <martin.becke@uni-due.de>,
	David Miller <davem@davemloft.net>, linux-sctp@vger.kernel.org,
	stable@kernel.org, Sridhar Samudrala <sri@us.ibm.com>
To: Thomas Dreibholz <dreibh@iem.uni-due.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:51248 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756077Ab0IWTST (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Sep 2010 15:18:19 -0400
Content-Disposition: inline
In-Reply-To: <201009181611.05665.dreibh@iem.uni-due.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 18, 2010 at 04:11:03PM +0200, Thomas Dreibholz wrote:
> On Donnerstag 16 September 2010, Vlad Yasevich wrote:
> > On 09/15/2010 03:43 PM, Andrew Morton wrote:
> > > Thanks, but please send patches via email, not via bugzilla.
> > > Documentation/SubmittingPatches has some tips.  Suitable recipients for
> > > this patch are, from the MAINTAINERS file:
> > > 
> > > M:      Vlad Yasevich <vladislav.yasevich@hp.com>
> > > M:      Sridhar Samudrala <sri@us.ibm.com>
> > > L:      linux-sctp@vger.kernel.org
> > > 
> > > but please just send it as a reply-to-all to this email so that everyone
> > > knows wht's happening.
> > > 
> > > I'd suggest that you also add the line
> > > 
> > > Cc: <stable@kernel.org>
> > > 
> > > to the end of the changelog so that we don't forget to consider the
> > > patch for backporting.
> > 
> > Hi Andrew
> > 
> > There is a much simpler solution to this problem that I posted to netdev
> > today.
> 
> Dear all,
> 
> Vlad's patch solves the problem. I hope this patch can go into the mailine 
> kernel soon, in order to get distribution kernels fixed as soon as possible. It 
> is relatively easy to trigger the denial of service problem, making all 
> systems providing SCTP-based services vulnerable to a remote DoS attack.
> 
> I have also been able to reproduce the problem with kernel 2.6.32, i.e. at 
> least all kernels from 2.6.32 to 2.6.36 are affected.

Is this in Linus's tree now?  If so, does anyone have the git commit id?

thanks,

greg k-h
