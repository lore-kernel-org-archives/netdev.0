From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 1/2] net/ipv4: fix IPv4 multicast over network
 namespaces
Date: Wed, 28 Mar 2012 04:46:08 -0400 (EDT)
Message-ID: <20120328.044608.766966633646030583.davem@davemloft.net>
References: <20120328015532.GA10832@kvack.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bcrl@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50269 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756283Ab2C1IqL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2012 04:46:11 -0400
In-Reply-To: <20120328015532.GA10832@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin LaHaise <bcrl@kvack.org>
Date: Tue, 27 Mar 2012 21:55:32 -0400

> When using multicast over a local bridge feeding a number of LXC guests
> using veth, the LXC guests are unable to get a response from other guests
> when pinging 224.0.0.1.  Multicast packets did not appear to be getting
> delivered to the network namespaces of the guest hosts, and further
> inspection showed that the incoming route was pointing to the loopback
> device of the host, not the guest.  This lead to the wrong network namespace
> being picked up by sockets (like ICMP).  Fix this by using the correct
> network namespace when creating the inbound route entry.
> 
> Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>

Applied.
