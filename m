From: Sebastian Kuzminsky <seb@highlab.com>
Subject: bug in my understanding (was Re: bug in tcp?)
Date: Mon, 23 Apr 2007 12:45:34 -0600
Message-ID: <E1Hg3Xa-0003gF-Vk@highlab.com>
References: <E1HdZgM-0001n2-F0@highlab.com> <462450C5.5080702@snapgear.com> <E1HdgLb-0005eU-Ji@highlab.com> <46246572.9020108@snapgear.com> <E1HdoAU-0001Ao-T8@highlab.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sccrmhc15.comcast.net ([63.240.77.85]:46466 "EHLO
	sccrmhc15.comcast.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161326AbXDWSpl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2007 14:45:41 -0400
Received: from seb (helo=highlab.com)
	by highlab.com with local-esmtp (Exim 4.67)
	(envelope-from <seb@highlab.com>)
	id 1Hg3Xa-0003gF-Vk
	for netdev@vger.kernel.org; Mon, 23 Apr 2007 12:45:35 -0600
In-reply-to: <E1HdoAU-0001Ao-T8@highlab.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sebastian Kuzminsky <seb@highlab.com> wrote:
> Philip Craig <philipc@snapgear.com> wrote:
> > Change the timeout or use keepalives.  I can't think of any other way.
> > The 5 days is a compromise between keeping valid connections and
> > timing out dead connections.  There will always be connections for
> > which it times out too fast or too slow.  I don't think there are
> > any drawbacks to increasing the timeout if you aren't a router,
> > but as long as there is a timeout, you need keepalives to be sure.
> 
> Thanks!  I'll add keepalives and rerun the tests, and I expect the
> problem to go away.

I reran the tests with keepalive enabled and it worked just fine.
Thanks for all your help, and sorry for the false alarm!


-- 
Sebastian Kuzminsky
