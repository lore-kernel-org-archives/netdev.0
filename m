From: Ben Greear <greearb@candelatech.com>
Subject: ppp and routing table rules.
Date: Thu, 01 Mar 2007 20:46:41 -0800
Message-ID: <45E7AC31.9030309@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:39759 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422881AbXCBEok (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Mar 2007 23:44:40 -0500
Received: from [71.112.198.166] (pool-71-112-198-166.sttlwa.dsl-w.verizon.net [71.112.198.166])
	(authenticated bits=0)
	by ns2.lanforge.com (8.13.4/8.13.4) with ESMTP id l224idv6031872
	for <netdev@vger.kernel.org>; Thu, 1 Mar 2007 20:44:39 -0800
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

I have a suspicion (but no proof at this time) that a rule like this:

20:     from all iif ppp400 lookup 10001

is not actually working for ppp interfaces.  Before I go adding printk 
statements, are there any
stats that would show if packets are hitting a particular rule or 
routing table?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


