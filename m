From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Subject: Question on how to select specific tx queues for tx multiqueue in
 2.6.27
Date: Wed, 13 Aug 2008 15:06:35 -0700
Message-ID: <80769D7B14936844A23C0C43D9FBCF0F13E0F9F5@orsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"shemminger@osdl.org" <shemminger@osdl.org>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:63669 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752133AbYHMWHK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 18:07:10 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is there a way in 2.6.27 to specify queue that a specific traffic type goes to in user space?  Using the multiqueue implementation in 2.6.26 it was possible to setup a multiqueue prio qdisc on the device and then target traffic to specific bands via tc which in turn would place the traffic on specific queues.  Below are the two use cases that are currently failing.

Case 1:  Filter arp traffic to a specific queue based on the ethertype being ETH_P_ARP
Current issue: all traffic is routed to queue 0

Case 2:  Filter ip traffic to a specific queue based on source/destination port number or ip address.
Current issue: traffic is routed to queue based on hash value determined by simple_tx_hash

At this point it appears 2.6.27 broke something that used to work in 2.6.2[3456], what should we do at this point to get multiqueue tx back to having the same user space configuration that worked before?

I would be glad to help provide more detail and/or testing of patches.

Thanks,
Alex
