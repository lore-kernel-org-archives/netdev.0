From: David Miller <davem@davemloft.net>
Subject: net-2.6.24 plans
Date: Wed, 03 Oct 2007 02:36:13 -0700 (PDT)
Message-ID: <20071003.023613.28785888.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50104
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756809AbXJCJgO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2007 05:36:14 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 5D896510001
	for <netdev@vger.kernel.org>; Wed,  3 Oct 2007 02:36:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I'm a bit behind after investigating the TCP performance issues that
turned out to be HW specific problems.  It's a bit of a
dissapointment, I thought maybe there was a cool bug to fix in TCP :-)

Anyways, that means there are patches backlogged in my inbox and it is
also about time to do the hopefully last rebase of the net-2.6.24
tree.

I merged in Jeff Garzik's and John Linville's latest and I'm running
the current tree on my workstation most of today with good results so
far.

Linus should release the final 2.6.23 very soon, let's kind of assume
it will happen over the next 3 or 4 days.

That means we need to bear down for the merge.  I plan to commit my
Neptune driver in it's current state, and that's the last new feature
going in.

You can help make the merge go swimmingly by picking some nagging
issue you noticed and track it down.  If you can figure out why
something happens but can't or don't have time to come up with
a fix, report what you've discovered.

If you can provide the fix too, all the better.

That's how I get backlogged, I'm working on A and notice some problem
with B, then I refuse to go back to A until I bring closure to B. :)
