From: Ben Greear <greearb@candelatech.com>
Subject: tcp wifi upload performance and lots of ACKs
Date: Mon, 04 Jun 2012 11:29:10 -0700
Message-ID: <4FCCFE76.3060304@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:49871 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753440Ab2FDS3L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 14:29:11 -0400
Received: from [192.168.100.111] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id q54ITAlD016231
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 4 Jun 2012 11:29:10 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm going some TCP performance testing on wifi -> LAN interface connections.  With
UDP, we can get around 250Mbps of payload throughput.  With TCP, max is about 80Mbps.

I think the problem is that there are way too many ACK packets, and bi-directional
traffic on wifi interfaces really slows things down.  (About 7000 pkts per second in
upload direction, 2000 pps download.  And the vast majority of the download pkts
are 66 byte ACK pkts from what I can tell.)

Kernel is 3.3.7+

Anyone know of any tuning parameters that would let the receiving socket wait a
bit longer and send more ACK data in fewer packets?

Packet traces and other info available if anyone wants to take a look.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
