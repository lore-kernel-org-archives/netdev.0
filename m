From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] udp: cleanup __udp4_lib_mcast_deliver
Date: Fri, 06 Nov 2009 00:42:15 -0800 (PST)
Message-ID: <20091106.004215.114490979.davem@davemloft.net>
References: <200911052033.21964.lgrijincu@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, opurdila@ixiacom.com
To: lgrijincu@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47611
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753875AbZKFIlt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 03:41:49 -0500
In-Reply-To: <200911052033.21964.lgrijincu@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>
Date: Thu, 5 Nov 2009 20:33:21 +0200

> 
> __udp4_lib_mcast_deliver always returned 0.
> It's caller can return 0 explicitly to make things clearer.
> 
> Also, we don't need the spin_lock() on the hslot to free the skb.
> 
> Signed-off-by: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>

I think the current code is much easier to understand than
your version.

Getting rid of the useless return value is fine, but the
new do{}while() loop et al. is less readable to me.

I'm not applying these two patches, sorry.
