From: Ben Greear <greearb@candelatech.com>
Subject: netlink stats:   Ability to get stats for a single device?
Date: Tue, 26 Oct 2010 12:31:12 -0700
Message-ID: <4CC72C80.9010802@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:41686 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751911Ab0JZTbN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 15:31:13 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id o9QJVCsB022347
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 12:31:12 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 From what I can tell, it's impossible to request stats for a single
network device via netlink.  When you have thousands of interfaces,
this means a lot of wasted effort to get stats for a particular
device.

Am I missing something, or do I just need to write up a patch
to have netlink pay attention to the ifindex?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

