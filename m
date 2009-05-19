From: Ben Greear <greearb@candelatech.com>
Subject: How fast can your 10G go?
Date: Tue, 19 May 2009 09:05:40 -0700
Message-ID: <4A12D8D4.2070303@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:55680 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721AbZESQFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 12:05:41 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id n4JG5e1u016092
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 19 May 2009 09:05:41 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've been running some tests on a new Nehalem based system
with a 2 port pci-e x8 10G NIC (ixgbe driver).

When using pktgen, max I can get is about 5.6Gbps tx + rx on both ports.  This is
about 22Gbps across the backplane, so I don't mean to complain :)

However, I'm curious if anyone has gotten any better performance on
some other system?  In particular, it seems that my system is bound by
the bus and/or the NIC.  Would I need to find something like a x16 slot
to have a chance at 10Gbps bi-directional on 2 ports?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

