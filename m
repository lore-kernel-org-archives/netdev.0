From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [net-2.6.26] [IPV6] Remove unused declarations in
 include/net/ip6_route.h.
Date: Thu, 10 Apr 2008 02:32:08 -0700 (PDT)
Message-ID: <20080410.023208.161440301.davem@davemloft.net>
References: <eb3ff54b0804011145na2b25bdo4cbe7f45457b1e1c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45645
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752198AbYDJJcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 05:32:08 -0400
In-Reply-To: <eb3ff54b0804011145na2b25bdo4cbe7f45457b1e1c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rami Rosen" <ramirose@gmail.com>
Date: Tue, 1 Apr 2008 21:45:15 +0300

> Hi,
>   This patches removes unused declarations in include/net/ip6_route.h
> 	
> 	1) Standlaone ip6_null_entry is no longer needed as it is replaced by
> 	the ip6_null_entry member of ipv6 (instance of struct netns_ipv6)	in
> 	struct net (as a result of Network Namespaces patches).
> 	
> 	
> 	2) These 3 methods from this same header are not defined anywhere:
> 	   ip6_rt_addr_add(), ip6_rt_addr_del(), rt6_sndmsg()
>
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied, thanks.
