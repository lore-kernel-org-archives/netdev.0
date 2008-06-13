From: Ben Greear <greearb@candelatech.com>
Subject: IPv6 question on policy based routing.
Date: Fri, 13 Jun 2008 14:53:24 -0700
Message-ID: <4852EC54.2080608@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([66.165.47.212]:46999 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752392AbYFMVxZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2008 17:53:25 -0400
Received: from [192.168.100.224] (static-71-121-249-218.sttlwa.dsl-w.verizon.net [71.121.249.218])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id m5DLrOtR020257
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 13 Jun 2008 14:53:25 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm trying to remove an IPv6 rule based on iif match.  Something
similar works for ipv4, but appears to fail for ipv6.  It works fine
if I leave out the 'iif [dev]' clause, but I want to have different
rules based on which interface the pkt comes in on...


[root@lanforge-D0-20 lanforge]# ip -6 ru show
...

11:     from all to 2000::2:2 iif rddVR0 lookup local


[root@lanforge-D0-20 lanforge]# ip -6 ru del from all to 2000::2:2 iff rddVR0 lookup local prio 11
Error: argument "iff" is wrong: Failed to parse rule type
[root@lanforge-D0-20 lanforge]# ip -6 ru del from all to 2000::2:2  lookup local prio 11
[root@lanforge-D0-20 lanforge]#

Is this supposed to work?

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

