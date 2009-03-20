From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 0/3] dsa driver updates
Date: Fri, 20 Mar 2009 20:49:25 +0100
Message-ID: <20090320194924.GT4738@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gary Thomas <gary@mlbassoc.com>,
	Jesper Dangaard Brouer <hawk@diku.dk>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:35443 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751898AbZCTTt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 15:49:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The biggest change here is the support for cascaded DSA switch chips
(patch 3/3), which we got working.  The patch ended up rather big,
but since all of the changes are interdependent, it was somewhat tricky
to split it up into smaller pieces and I decided against it.

Note that patch #3 changes the DSA platform driver API to accommodate
multiple switch chips.  It updates the current in-tree users (under
arch/arm) accordingly.
