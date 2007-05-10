From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 00/17] sky2 update for 2.6.22
Date: Wed, 9 May 2007 22:08:20 -0700
Message-ID: <20070509220820.337bedb8@freepuppy>
References: <20070509034949.624934448@linux-foundation.org>
	<46414B30.6050603@garzik.org>
	<20070509074811.23ba0bb9@freekitty>
	<464258D5.5040402@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Greg KH <greg@kroah.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:57841 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754585AbXEJFI2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2007 01:08:28 -0400
In-Reply-To: <464258D5.5040402@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 09 May 2007 19:27:17 -0400
Jeff Garzik <jeff@garzik.org> wrote:

> Stephen Hemminger wrote:
> > On Wed, 09 May 2007 00:16:48 -0400
> > Jeff Garzik <jeff@garzik.org> wrote:
> > 
> >> Stephen Hemminger wrote:
> >>> Patches are against netdev-2.6 upstream code branch.
> >>>
> >>> This includes a several bug fixes, and code cleanup to use standard
> >>> functions. There are a couple of PCI changes. One bug fix, and moving
> >>> common code in PCI base.
> >> The standard development process is:
> >>
> >> 	* new code gets pushed to me during 2.6.X-rc
> >> 	* that code is auto-propagated to akpm's -mm tree for
> >> 	  additional exposure
> >> 	* merge window opens
> >> 	* I push upstream
> >>
> >> That ensures code gets at least /some/ additional review, testing, 
> >> "settling" time.
> > 
> > Sorry for the late merge, but between the closing of OSDL office and
> > the fixing of critical bugs the other stuff got pushed into the "next release"
> > bin and wasn't really ready until now.
> > 
> >> This is a late date to be expecting stuff to be pushed straight into 2.6.22.
> > 
> > Then hold it for 2.6.23.
> 
> You sure you don't want to split off the bug fixes, and submit those for 
> 2.6.22?
> 
> An oops fix is certainly 2.6.22 material...
> 

I'll split into groups and let you decide where the cut off is:

1) crashes for stable and 2.6.22
2) stuff that should be fixed in 2.6.22 but isn't stable material
3) newer stuff for -mm or later release

Also, I just got loaner versions of the just release 88e807X hardware
so it maybe possible to get that working before 2.6.22 final.



-- 
Stephen Hemminger <shemminger@linux-foundation.org>
