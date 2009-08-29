From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Update Neighbor Cache when IPv6 RA is received on a
 router
Date: Sat, 29 Aug 2009 00:04:27 -0700 (PDT)
Message-ID: <20090829.000427.235911462.davem@davemloft.net>
References: <1250381994-21329-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david.ward@ll.mit.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52739
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751609AbZH2HEP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2009 03:04:15 -0400
In-Reply-To: <1250381994-21329-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ward <david.ward@ll.mit.edu>
Date: Sat, 15 Aug 2009 20:19:54 -0400

> When processing a received IPv6 Router Advertisement, the kernel
> creates or updates an IPv6 Neighbor Cache entry for the sender --
> but presently this does not occur if IPv6 forwarding is enabled
> (net.ipv6.conf.*.forwarding = 1), or if IPv6 Router Advertisements
> are not accepted (net.ipv6.conf.*.accept_ra = 0), because in these
> cases processing of the Router Advertisement has already halted.
> 
> This patch allows the Neighbor Cache to be updated in these cases,
> while still avoiding any modification to routes or link parameters.
> 
> This continues to satisfy RFC 4861, since any entry created in the
> Neighbor Cache as the result of a received Router Advertisement is
> still placed in the STALE state.
> 
> Signed-off-by: David Ward <david.ward@ll.mit.edu>

This seems OK, applied to net-next-2.6

Thanks.
