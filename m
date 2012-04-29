From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/4 net-next] net/ipv6/udp: UDP encapsulation: move
 socket locking into udpv6_queue_rcv_skb()
Date: Sat, 28 Apr 2012 22:31:35 -0400 (EDT)
Message-ID: <20120428.223135.1943325920224600589.davem@davemloft.net>
References: <20120427182358.GF17021@kvack.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, netdev@vger.kernel.org
To: bcrl@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54790 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755894Ab2D2Cbm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2012 22:31:42 -0400
In-Reply-To: <20120427182358.GF17021@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin LaHaise <bcrl@kvack.org>
Date: Fri, 27 Apr 2012 14:23:59 -0400

> In order to make sure that when the encap_rcv() hook is introduced it is
> not called with the socket lock held, move socket locking from callers into
> udpv6_queue_rcv_skb(), matching what happens in IPv4.
> 
> Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>

Applied.
