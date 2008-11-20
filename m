From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-next-2.6 2008-11-18
Date: Thu, 20 Nov 2008 05:03:48 -0800 (PST)
Message-ID: <20081120.050348.134053835.davem@davemloft.net>
References: <20081119000852.GB19756@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	sfr@canb.auug.org.au
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59107
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752629AbYKTNDs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 08:03:48 -0500
In-Reply-To: <20081119000852.GB19756@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Tue, 18 Nov 2008 19:08:52 -0500

> Here is another big round of updates intended for 2.6.29.  This batch is
> mostly driver updates as well as a bunch of file movement.  Also, some
> patches from me are working towards refactoring/minimizing the old
> ieee80211 component into a support library for ipw2100 and ipw2200 and
> also collecting more code into lib80211 for sharing between more
> drivers.
> 
> Please let me know if there are problems!
 ...
> P.S.  I have included a merge-test branch as an example of how the
> merge conflicts with the wireless-2.6 pull request from today should
> be resolved.

John, I took the stable fixes and those are in the pull request
I just sent to Linus.

Once he takes that in I'll merge those bits into net-next-2.6 and
resolve the conflicts created solely by that merge.

What I think makes sense right now for your net-next-2.6 stuff is
for you to just sit tight until I do the merge, then you can respin
your tree, include Rami Rosen's build fix, and take care of the
remaining merge issues at the same time.

I'll post on netdev when I do the merging, as I usually do.

Thanks!
