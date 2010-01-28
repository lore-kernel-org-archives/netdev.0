From: Alexander Lapidus <alex@wildpark.net>
Subject: Intel 82598, RSS and PPPoE
Date: Thu, 28 Jan 2010 13:34:50 +0200
Message-ID: <201001281334.51123.alex@wildpark.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.wildpark.net ([217.77.208.132]:58238 "EHLO
	mail.wildpark.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752421Ab0A1LoM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2010 06:44:12 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.wildpark.net (Postfix) with ESMTP id EE3FBBB5376
	for <netdev@vger.kernel.org>; Thu, 28 Jan 2010 13:34:51 +0200 (EET)
Received: from mail.wildpark.net ([127.0.0.1])
	by localhost (mail.wildpark.net [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id eknXLMU8BWGC for <netdev@vger.kernel.org>;
	Thu, 28 Jan 2010 13:34:51 +0200 (EET)
Received: from lapidus.wildpark.net (unknown [192.168.2.21])
	by mail.wildpark.net (Postfix) with ESMTP id C88C3BB52D8
	for <netdev@vger.kernel.org>; Thu, 28 Jan 2010 13:34:51 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, everybody!
 Help is needed in such case. We have a linux-box, running under CentOS 5.4 
with a latest kernel. Intel 10 Gigabit AF DA Dual Port Server Adapter (based 
on Intel 82598EB) is used for routing purposes. Linux-box is dual CPU Xeon 
E5530 server.  Interface eth0 is an uplink to the network core with pure IPv4 
trafic on it. Interface eth1 is an downlink to customers. We have 3000 802.1q 
VLANs on it. PPPoE server daemon is running on all VLAN interfaces. So we have 
ethernet frames with 802.1q VLAN tag and PPPoE header incapsulated. Our 
problem is with RX packet distribution between rx-queues on this  interface. 
All those packets are coming to RX-queue-0. As i understood from Intel 
specification on 82598 chipset, problem is with RSS, which can't decode PPPoE 
header, so packet is going only to queue 0. My question is how to force such 
packets to spread between different queues. May be it's possible to use VMDq 
in this configuration, or any other solution?

P.S. We tried this configuration with in-kernel driver and with latest driver 
from Intel (ixgbe-2.0.44.14). Situation is the same.


-- 
Thanks a lot,
Alexander Lapidus
AL546-RIPE
WildPark ISP,
Nikolaev, UA
