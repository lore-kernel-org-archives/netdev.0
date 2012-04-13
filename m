From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/garp: fix GID rbtree ordering
Date: Fri, 13 Apr 2012 13:10:48 -0400 (EDT)
Message-ID: <20120413.131048.941392773930795760.davem@davemloft.net>
References: <1333980833-12355-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jorge@dti2.net
To: david.ward@ll.mit.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50765 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751123Ab2DMRLG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 13:11:06 -0400
In-Reply-To: <1333980833-12355-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ward <david.ward@ll.mit.edu>
Date: Mon, 9 Apr 2012 10:13:53 -0400

> The comparison operators were backwards in both garp_attr_lookup and
> garp_attr_create, so the entire GID rbtree was in reverse order.
> (There was no practical side effect to this though, except that PDUs
> were sent with attributes listed in reverse order, which is still
> valid by the protocol. This change is only for clarity.)
> 
> Signed-off-by: David Ward <david.ward@ll.mit.edu>

Applied to net-next, thanks David.
