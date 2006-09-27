From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] softmac: Fix WX and association related races
Date: Thu, 28 Sep 2006 08:23:23 +1000
Message-ID: <1159395803.18293.72.camel@localhost.localdomain>
References: <200609271726.34305.mb@bu3sch.de>
	 <451AA446.7060009@lwfinger.net>  <200609271950.47430.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, Larry Finger <Larry.Finger@lwfinger.net>,
	Christian <email@christianhoffmann.info>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:40362 "EHLO gate.crashing.org")
	by vger.kernel.org with ESMTP id S1031146AbWI0WYm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 18:24:42 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200609271950.47430.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-09-27 at 19:50 +0200, Michael Buesch wrote:
> On Wednesday 27 September 2006 18:18, Larry Finger wrote:
> > Michael Buesch wrote:
> > > This fixes some race conditions in the WirelessExtension
> > > handling and association handling code.
> > > 
> > > Signed-off-by: Michael Buesch <mb@bu3sch.de>
> > > 
> > > ---
> > 
> > This patch doesn't apply.
> 
> Oh, linville merged stuff on the 25th. That's the day I updated
> my tree to do this patch. But seems like I did it just before
> the merge.
> Who could suspect that linville merges something. :D
> *me runs away*
> 
> Anyway. Here's an updated patch.

Which still doesn't apply to 2.6.18.

I won't try some random other git tree to test things, it's simply not
feasible for me and we need something we can give to distros to backport
so they have something remotely stable (I'm thinking for example about
the upcoming ubuntu edgy which is coming out soon an a 2.6.17 base).

Ben.


