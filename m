From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] e1000: limit udelay for phy changes to 10000us
Date: Sun, 21 Apr 2013 16:27:13 +0200
Message-ID: <20130421142713.GU16732@two.firstfloor.org>
References: <1366515095-17734-1-git-send-email-andi@firstfloor.org>
 <1366515285.2209.17.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	Andi Kleen <ak@linux.intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([193.170.194.197]:49882 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753693Ab3DUOfA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Apr 2013 10:35:00 -0400
Content-Disposition: inline
In-Reply-To: <1366515285.2209.17.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 20, 2013 at 08:34:45PM -0700, Jeff Kirsher wrote:
> On Sat, 2013-04-20 at 20:31 -0700, Andi Kleen wrote:
> > From: Andi Kleen <ak@linux.intel.com>
> > 
> > If you really want 100000us you should really use mdelay or so.
> > 
> > Found by the LTO kernel build
> > 
> > Signed-off-by: Andi Kleen <ak@linux.intel.com>
> > ---
> >  drivers/net/ethernet/intel/igb/e1000_phy.c |    6 +++---
> >  1 files changed, 3 insertions(+), 3 deletions(-) 
> 
> Thanks Andi, I will add the patch to my igb queue.  Do you want me to
> fix up the patch title as well? :-) (s/e1000/igb/)

Sure please fix.

BTW I'm not sure my fix/value is right. If you really need 100000us you need
some other mechanism to wait.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
