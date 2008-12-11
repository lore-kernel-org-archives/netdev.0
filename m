From: Poornima Kamath <poornimak@gslab.com>
Subject: Detecting backup slaves of bonding interface in network driver
Date: Thu, 11 Dec 2008 18:04:31 +0530
Message-ID: <494108D7.3040304@gslab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from padma.gslab.com ([59.163.66.102]:49698 "HELO padma.gslab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755450AbYLKNHZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Dec 2008 08:07:25 -0500
Received: from rohini.gs-lab.com (unknown [172.20.50.32])
	(Authenticated sender: poornimak)
	by padma.gslab.com (Postfix) with ESMTP id B3F6B1770584
	for <netdev@vger.kernel.org>; Thu, 11 Dec 2008 17:37:24 +0530 (IST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,
I have a network driver which creates virtual ethernet interfaces. I am 
using the bonding driver in the active backup mode for failover.
I want to detect the interfaces which are backup slaves in the driver.
I found that the  bonding driver sets the IFF_SLAVE_INACTIVE private 
flag of net_device structure for all the backup slaves.
But I dont see any callbacks in my driver when this flag is set.
I am planning to check the netdevice flags in the driver. Is it 
recommended to check the private flags of net_device ?
Or is there some better way in which I can find the backup slaves?

Thanks,
Poornima
