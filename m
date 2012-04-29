From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/4 net-next] net/ipv6/udp: UDP encapsulation: break
 backlog_rcv into __udpv6_queue_rcv_skb
Date: Sat, 28 Apr 2012 22:31:29 -0400 (EDT)
Message-ID: <20120428.223129.1512957376766834022.davem@davemloft.net>
References: <20120427182321.GE17021@kvack.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, netdev@vger.kernel.org
To: bcrl@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54787 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755880Ab2D2Cbj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2012 22:31:39 -0400
In-Reply-To: <20120427182321.GE17021@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin LaHaise <bcrl@kvack.org>
Date: Fri, 27 Apr 2012 14:23:21 -0400

> This is the first step in reworking the IPv6 UDP code to be structured more
> like the IPv4 UDP code.  This patch creates __udpv6_queue_rcv_skb() with
> the equivalent sematics to __udp_queue_rcv_skb(), and wires it up to the
> backlog_rcv method.
> 
> Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>

Applied.
