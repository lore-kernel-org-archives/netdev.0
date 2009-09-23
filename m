From: Ben Greear <greearb@candelatech.com>
Subject: Getting physical packet counts with LRO enabled with ixgbe?
Date: Wed, 23 Sep 2009 09:40:43 -0700
Message-ID: <4ABA4F8B.6040504@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:47027 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751338AbZIWQkk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2009 12:40:40 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id n8NGehN1004302
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 23 Sep 2009 09:40:43 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I notice that with LRO enabled, the interface stats count the LRO'd pkts,
not the physical ones on the wire.

I also tried using ethtool -S, but it seems those counters are the same.

Is there any way to get the actual rx/tx packet count on the wire?

Also, for the rx/tx bytes, I assume that isn't counting the protocol headers
for the physical pkts that have been merged into a single LRO packet.  Is
there any way to get the wire stats for bytes as well?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

