From: Ben Greear <greearb@candelatech.com>
Subject: Ixgbe question
Date: Mon, 10 Mar 2008 14:27:00 -0700
Message-ID: <47D5A7A4.30606@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([66.165.47.212]:58497 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753143AbYCJV1D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2008 17:27:03 -0400
Received: from [192.168.100.224] (static-71-121-249-218.sttlwa.dsl-w.verizon.net [71.121.249.218])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id m2ALR1EA007622
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 10 Mar 2008 14:27:03 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a pair of IXGBE NICs in a system, and notice a strange
case where the NIC is not always 'UP' after my programs finish
trying to configure it.  I haven't noticed this with any other
NICs, but I also just moved to 2.6.23.17 from 23.9 and 23.14.

I see this in the logs:

ADDRCONF(NETDEV_UP): eth0: link is not ready

It would seem to me that we should be able to set the admin
state to UP, even if the link is not up??

Kernel is 2.6.23.17 plus my hacks.   Ixgbe driver is version 1.3.7.8-lro.

Hardware is quad-core Intel, 2 build-in e1000, 2-port ixgbe (CX4) chipset NIC
on a pcie riser.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

