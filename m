From: Ben Greear <greearb@candelatech.com>
Subject: Specifying netdev name on kernel boot?
Date: Thu, 15 Aug 2013 08:50:19 -0700
Message-ID: <520CF8BB.2080702@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:49117 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755331Ab3HOPuV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 11:50:21 -0400
Received: from [192.168.100.226] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id r7FFoJnO028585
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 15 Aug 2013 08:50:20 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems they finally broke udev in Fedora 19...it can no longer
rename ethX to ethY, for whatever reason.

Is there a way to specify the naming on the kernel command line?

I found something in google that made me think this might work:

ifname=eth0:00:30:48:fc:17:a2 ifname=eth1:00:30:48:fc:17:a3 ifname=eth2:00:e0:ed:1c:ec:e4 ifname=eth3:00:e0:ed:1c:ec:e5

but it doesn't seem to have any affect.

I'm using ixgbe and e1000e drivers, loaded as modules, in case that matters.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
