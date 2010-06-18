From: Ben Greear <greearb@candelatech.com>
Subject: Can I limit number of rx queues for igb (and other Intel drivers)?
Date: Fri, 18 Jun 2010 15:39:38 -0700
Message-ID: <4C1BF5AA.8010209@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:35381 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753631Ab0FRWjk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jun 2010 18:39:40 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id o5IMddEM014367
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 18 Jun 2010 15:39:39 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm using pktgen to send a stream of packets with varying source and destination
IP addresses.  It appears that the fancy rx logic of the NIC (I'm using igb for this test)
causes the received packets to appear on random rx queues and so be received out
of order in the network core.

I do not see the out-of-order issue when using a single source/dest IP address
for the pktgen packets.

So, is there a way to tell igb to use only a single rx queue?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

