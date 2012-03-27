From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH ipv4 multicast] Fix IPv4 multicast over network
 namespaces
Date: Tue, 27 Mar 2012 17:35:41 -0400 (EDT)
Message-ID: <20120327.173541.1721499825104013533.davem@davemloft.net>
References: <20120327161228.GA2367@kvack.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bcrl@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45959 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754402Ab2C0Vfp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 17:35:45 -0400
In-Reply-To: <20120327161228.GA2367@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin LaHaise <bcrl@kvack.org>
Date: Tue, 27 Mar 2012 12:12:28 -0400

> When using multicast over a local bridge feeding a number of LXC guests
> using veth, the LXC guests are unable to get a response from other guests
> when pinging 224.0.0.1.  Multicast packets did not appear to be getting
> delivered to the network namespaces of the guest hosts, and further
> inspection showed that the incoming route was pointing to the loopback
> device of the host, not the guest.  This lead to the wrong network namespace
> being picked up by sockets (like ICMP).  Fix this by using the correct
> network namespace when creating the inbound route entry.

No signoff.

No proper subsystem prefix in Subject line (should be "ipv4: " here)

And third you've been warned about this repeatedly in your previous
patch postings.

Therefore I'm not applying this.
