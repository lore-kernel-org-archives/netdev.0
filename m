From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/7 net-next-2.6] tipc: Optimization to multicast name
 lookup algorithm
Date: Mon, 14 Jul 2008 22:45:41 -0700 (PDT)
Message-ID: <20080714.224541.257319476.davem@davemloft.net>
References: <1215725171-10094-1-git-send-email-allan.stephens@windriver.com>
	<1215725171-10094-8-git-send-email-allan.stephens@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60022
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753578AbYGOFpl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 01:45:41 -0400
In-Reply-To: <1215725171-10094-8-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>
Date: Thu, 10 Jul 2008 17:26:11 -0400

> This patch simplifies and speeds up TIPC's algorithm for identifying
> on-node and off-node destinations that overlap a multicast name
> sequence range.  Rather than traversing the list of all known name
> publications within the cluster, it now traverses the (potentially
> much shorter) list of name publications made by the node itself, and
> determines if any off-node destinations exist by comparing the sizes
> of the two lists.  (Since the node list must be a subset of the
> cluster list, a difference in sizes means that at least one off-node
> destination must exist.)
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>

Also applied, thanks a lot.
