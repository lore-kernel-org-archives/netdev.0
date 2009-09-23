From: Ben Greear <greearb@candelatech.com>
Subject: Why is LRO off by default on ixgbe?
Date: Wed, 23 Sep 2009 09:29:59 -0700
Message-ID: <4ABA4D07.50107@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:43783 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751232AbZIWQ34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2009 12:29:56 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id n8NGTxqd003314
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 23 Sep 2009 09:29:59 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I just noticed that enabling LRO on ixgbe lets me reach about 9Gbps receive on two
NICs concurrently in an NFS test, where I was only getting about 6Gbps w/out it (1500 MTU).

Why is LRO disabled by default?

Thanks,
Ben
-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

