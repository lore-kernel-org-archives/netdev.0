From: Ben Greear <greearb@candelatech.com>
Subject: SCTP performance?
Date: Fri, 09 Aug 2013 16:11:48 -0700
Message-ID: <52057734.6060306@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:55539 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031447Ab3HIXLw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 19:11:52 -0400
Received: from [192.168.100.226] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id r79NBm8v002564
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 9 Aug 2013 16:11:48 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I just added some support for SCTP to my traffic-generator tool.

I tried to send 1Gbps of traffic, bi-directional, across two
10G interfaces.  TCP does this without any trouble at all,
but SCTP was asymetric and never got above around 700Mbps,
and was usually stuck at < 500Mbps.

perf top didn't show any obvious CPU bottlenecks.

Has anyone done any recent performance testing with SCTP?

I'd be interested to know the results if so...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
