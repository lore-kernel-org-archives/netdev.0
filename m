From: David Miller <davem@davemloft.net>
Subject: READ ME Major net-2.6.24 rebase
Date: Sat, 15 Sep 2007 15:39:36 -0700 (PDT)
Message-ID: <20070915.153936.41632998.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, linville@tuxdriver.com, akpm@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46942
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751954AbXIOWjh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Sep 2007 18:39:37 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I've fully rebased the tree at:

	kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.24.git

Also, I've fully integrated both John Linville's wireless
infrastructure and driver updates, as well as Jeff Garzik's
upstream netdevice changes.

This should resolve all of the merging conflicts that were
occuring between these trees, and from now until the
2.6.24 merge window opens Jeff and I will keep our
trees close together so that there is no divergence.

I've sanity-strapped this thing by doing a make allmodconfig
on sparc64, and I'm running this tree on my SunBlade1500
workstation with no problems so far.

With this much churn there is guarenteed to be a small issue
here or there, and we'll fix those up.

Andrew, this means you can stop pulling in Jeff's tree for the
time being, everything is in my tree above.

Enjoy.
