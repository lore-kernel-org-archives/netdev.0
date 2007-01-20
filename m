From: Ben Greear <greearb@candelatech.com>
Subject: Why are subnet routes lost when IP is flushed?
Date: Sat, 20 Jan 2007 15:34:52 -0800
Message-ID: <45B2A71C.3040108@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:42068 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750871AbXATXcx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Jan 2007 18:32:53 -0500
Received: from [71.112.218.242] (pool-71-112-218-242.sttlwa.dsl-w.verizon.net [71.112.218.242])
	(authenticated bits=0)
	by ns2.lanforge.com (8.13.4/8.13.4) with ESMTP id l0KNWqJB021232
	for <netdev@vger.kernel.org>; Sat, 20 Jan 2007 15:32:52 -0800
To: NetDev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I am setting up a routing table associated with a network device.  Several
subnet routes are added to this table.

I notice that when I do 'ip addr flush dev [dev-name]' all of the subnet 
routes
destined out of 'dev-name' are purged!

Is this a bug, or is it supposed to work like this?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


