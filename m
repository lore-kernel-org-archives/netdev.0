From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Fw: [Bridge] IGMP snooping not filtering multicast messages
Date: Wed, 8 Jun 2011 08:44:34 -0700
Message-ID: <20110608084434.28bfc18c@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59399 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756597Ab1FHPoq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 11:44:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Tue, 31 May 2011 19:48:52 +0200 (CEST)
From: "maxd@inwind.it" <maxd@inwind.it>
To: bridge@lists.linux-foundation.org
Subject: [Bridge] IGMP snooping not filtering multicast messages


Hi. I have a partial mesh network composed by Linux nodes. Each linux node may 
have up to 4 ethernet interfaces, which are exploited to create point-to-point 
connections with other linux nodes. I have bridged the ethernet interfaces in 
each node, so that the whole network, which is physically composed by a set of 
network segments, appears as a single layer-2 domain. I have enabled spanning 
tree to avoid loops. In this scenario, I would like to exploit the IGMP 
snooping functionality, but it seems that it is not working properly. I am 
using iperf to set a multicast source (iperf client) and a few multicast sinks 
in the network (iperf servers). I am using tcpdump, instead, to check where 
multicast messages are received. What I notice is that there is apparently no 
filtering of the multicast messages, that are always flooded in the network. I 
tried to repeat the test varying the multicast address (paying attention not to 
get reserved addresses), with and without multicast clients set, with the 
multicast_router option set to 1 (default) and to 0. To double check that IGMP 
is working, I have also tried to disable it; the only difference I see is that 
tcpdump does not show IGMP query messages when the IGMP snooping is disabled. 
So, I am wondering if the IGMP snooping implementation currently available can 
deal with my scenario. In particular, I would stress the following points that 
I think might be relevant:
-I have no multicast router in my network (it looks like a single stand-alone 
lan)
-Each node acts as a bridge, so I have multiple bridges in my network, 
connected each other.
Any idea would be greatly appreciated!

Massimiliano
_______________________________________________
Bridge mailing list
Bridge@lists.linux-foundation.org
https://lists.linux-foundation.org/mailman/listinfo/bridge
