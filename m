From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] vlan: allow nested vlan_do_receive()
Date: Sun, 30 Oct 2011 04:44:03 -0400 (EDT)
Message-ID: <20111030.044403.1905289523670344598.davem@davemloft.net>
References: <1319904819.2586.45.camel@edumazet-laptop>
	<20111029162839.GC2053@minipsycho.orion>
	<20111030083811.GA2059@minipsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, john.r.fastabend@intel.com,
	jesse@nicira.com, hans.schillstrom@ericsson.com, mbizon@freebox.fr,
	netdev@vger.kernel.org, fubar@us.ibm.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41419 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753007Ab1J3IoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2011 04:44:20 -0400
In-Reply-To: <20111030083811.GA2059@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Sun, 30 Oct 2011 09:38:12 +0100

> Sat, Oct 29, 2011 at 06:28:40PM CEST, jpirko@redhat.com wrote:
>>Sat, Oct 29, 2011 at 06:13:39PM CEST, eric.dumazet@gmail.com wrote:
>>>commit 2425717b27eb (net: allow vlan traffic to be received under bond)
>>>broke ARP processing on vlan on top of bonding.
 ...
>>>Packet is dropped in arp_rcv() because its pkt_type was set to
>>>PACKET_OTHERHOST in the first vlan_do_receive() call, since no eth0.103
>>>exists.
>>>
>>>We really need to change pkt_type only if no more rx_handler is about to
>>>be called for the packet.
>>>
>>>Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>>>---
>>>V2 : change the vlan_do_receive() added argument to be a boolean
 ...
> Reviewed-by: Jiri Pirko <jpirko@redhat.com>

Applied, thanks everyone.
