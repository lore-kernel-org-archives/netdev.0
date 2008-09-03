From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 00/17] mv643xx_eth: changes for 2.6.28
Date: Wed,  3 Sep 2008 14:29:27 +0200
Message-ID: <1220444984-20150-1-git-send-email-buytenh@wantstofly.org>
Cc: Dale Farnsworth <dale@farnsworth.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:52885 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752204AbYICM3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 08:29:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The attached set of mv643xx_eth patches is what I think should be good
to go into 2.6.28.

Among the changes are moving all work to NAPI context, simplifying
the locking (getting rid of the driver-private per-interface spinlock),
transmit multiqueue support, and some misc cleanups/speedups.

With these changes, I'm getting close to finishing the set of changes
that I had planned to make to the mv643xx_eth driver, and it is now
finally approaching a state where I don't totally hate it anymore.  I
suppose that this'll be the last major set of patches for it.

There are a couple more patches in my tree that still need some
discussion -- I'll be posting those as well.
