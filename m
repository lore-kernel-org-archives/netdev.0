From: Ranko Zivojnovic <ranko@spidernet.net>
Subject: Re: [Bugme-new] [Bug 8736] New: New TC deadlock scenario
Date: Sat, 14 Jul 2007 19:45:35 +0300
Message-ID: <1184431535.14136.62.camel@localhost.localdomain>
References: <bug-8736-10286@http.bugzilla.kernel.org/>
	 <20070711111803.f8f97d98.akpm@linux-foundation.org>
	 <469521F0.1010803@trash.net>  <4698EF3B.5070907@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@kernel-bugs.osdl.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MPP-Goya.spidernet.net ([194.154.128.52]:23665 "EHLO
	mail0pop.spidernet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755048AbXGNQq7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2007 12:46:59 -0400
In-Reply-To: <4698EF3B.5070907@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2007-07-14 at 17:43 +0200, Patrick McHardy wrote:
> Patrick McHardy wrote:
> > Andrew Morton wrote:
> > 
> >>>http://bugzilla.kernel.org/show_bug.cgi?id=8736
> >>>
> >>>Here is another scenario I bumped onto - qdisc_watchdog_cancel() and
> >>>qdisc_restart() deadlock.
> >>>
> >>>[...]
> >>>DEADLOCK!
> > 
> > 
> > 
> > Good catch.
> > 
> > Please try reverting commit 1936502d00ae6c2aa3931c42f6cf54afaba094f2,
> > that should fix it.
> 
> 
> Ranko, did you get a chance to test this? I've attached the patch
> since it doesn't revert cleanly ..

I have the commit reverted on my tree and have been testing it along
with the other changes to qdisc code I'm currently doing and it does
rectify the problem.

Acked-by: Ranko Zivojnovic <ranko@spidernet.net>


