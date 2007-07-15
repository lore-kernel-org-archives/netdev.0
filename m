From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 8736] New: New TC deadlock scenario
Date: Sat, 14 Jul 2007 20:49:51 -0700 (PDT)
Message-ID: <20070714.204951.112046547.davem@davemloft.net>
References: <469521F0.1010803@trash.net>
	<4698EF3B.5070907@trash.net>
	<1184431535.14136.62.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@kernel-bugs.osdl.org
To: ranko@spidernet.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55484
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751448AbXGODtt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2007 23:49:49 -0400
In-Reply-To: <1184431535.14136.62.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ranko Zivojnovic <ranko@spidernet.net>
Date: Sat, 14 Jul 2007 19:45:35 +0300

> On Sat, 2007-07-14 at 17:43 +0200, Patrick McHardy wrote:
> > Patrick McHardy wrote:
> > > Andrew Morton wrote:
> > > 
> > >>>http://bugzilla.kernel.org/show_bug.cgi?id=8736
> > >>>
> > >>>Here is another scenario I bumped onto - qdisc_watchdog_cancel() and
> > >>>qdisc_restart() deadlock.
> > >>>
> > >>>[...]
> > >>>DEADLOCK!
> > > 
> > > 
> > > 
> > > Good catch.
> > > 
> > > Please try reverting commit 1936502d00ae6c2aa3931c42f6cf54afaba094f2,
> > > that should fix it.
> > 
> > 
> > Ranko, did you get a chance to test this? I've attached the patch
> > since it doesn't revert cleanly ..
> 
> I have the commit reverted on my tree and have been testing it along
> with the other changes to qdisc code I'm currently doing and it does
> rectify the problem.
> 
> Acked-by: Ranko Zivojnovic <ranko@spidernet.net>

Applied, thanks everyone.
