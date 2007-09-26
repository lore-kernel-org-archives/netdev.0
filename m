From: David Miller <davem@davemloft.net>
Subject: net-2.6.24 rebased...
Date: Tue, 25 Sep 2007 23:33:44 -0700 (PDT)
Message-ID: <20070925.233344.43202361.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, jeff@garzik.org, akpm@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53012
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750802AbXIZGdu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2007 02:33:50 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Ok the rebase is complete and I integrated all of the
"easy" stuff in my backlog.  In the usual spot:

	kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git

John, one patch didn't go in cleanly after I removed the
Z1211 driver.  I put it here for your consideration so it
doesn't get lost:

	http://vger.kernel.org/~davem/0433-Z1211-Fix-TX-status-reports.patch

What probably needs to happen is some other changes that
were in z1211 need to go into the non-mac80211 driver and
then this patch applies correctly.

I tried the simple thing to rename the directory in the patch
and that didn't work, obviously :-)

Jeff, if you have any pending driver bits please toss them my
way as most of my backlog is clear now.

Andrew, I applied a good chunk of the driver build fixes you had
accumulated.  I think I missed one or two, so please check that out
and send my way the ones that I missed.

Thanks!
