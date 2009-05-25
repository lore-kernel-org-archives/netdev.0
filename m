From: Robert Olsson <robert@robur.slu.se>
Subject: lookup in fib tables with NETLINK_FIB_LOOKUP
Date: Mon, 25 May 2009 15:45:19 +0200
Message-ID: <18970.41199.241372.614981@robur.slu.se>
References: <31436f4a0905250344md9c75fbud4540d48ce7f2a0d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Robert.Olsson@data.slu.se
To: David Shwatrz <dshwatrz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from robur.slu.se ([130.238.98.12]:48335 "EHLO robur.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751711AbZEYNpV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 May 2009 09:45:21 -0400
In-Reply-To: <31436f4a0905250344md9c75fbud4540d48ce7f2a0d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Shwatrz writes:

 > I would appreciate if someone can write a short and brief explanation about
 > the usage of  NETLINK_FIB_LOOKUP. It enables to perform a fib_lookup()
 > via netlink.

 It is/was for verifying the route selection process from userland via netlink.
 This was added when fib_trie was introduced and in this case we're comparing 
 NETLINK_FIB_LOOKUP result with a userland program doing longest prefix match 
 on the same routing table. 

 > What's is its usage ? Are there any user space tools which use it ?

 Not what I'm aware of. We did a test program..

 > I grepped for "NETLINK_FIB_LOOKUP" under iproute2 source code and no hit.
 > Is there any difference between performing a lookup in the routing
 > tables (as "ip route ...")
 > and performing a lookup with NETLINK_FIB_LOOKUP?

 iproute normally dumps the table, it doesn't look up a particular route
 as done via the RX softirq.
 
 Cheers
					--ro

