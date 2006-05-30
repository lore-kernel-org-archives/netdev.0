From: Ben Greear <greearb@candelatech.com>
Subject: avahi error:  IP_ADD_MEMBERSHIP failed: No buffer space available
Date: Tue, 30 May 2006 11:07:47 -0700
Message-ID: <447C89F3.5040909@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:13031 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S932371AbWE3SHr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 May 2006 14:07:47 -0400
Received: from [71.112.216.116] (pool-71-112-216-116.sttlwa.dsl-w.verizon.net [71.112.216.116])
	(authenticated bits=0)
	by ns2.lanforge.com (8.13.4/8.13.4) with ESMTP id k4UI7kgj029920
	for <netdev@vger.kernel.org>; Tue, 30 May 2006 11:07:46 -0700
To: NetDev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an FC5 64-bit system with 1GB RAM and dual-core Opteron.
When I create a bunch of virtual interfaces, I see this in
/var/log/messages.  The kernel is 2.6.16.16 plus my hacks.

At first look, it doesn't appear I actually need the avahi tool, so
I'm just going to disable it.  But, I thought someone might
want to be aware of the problem...

May 30 11:01:37 x64-1u avahi-daemon[2022]: Joining mDNS multicast group on inter
face eth2#16.IPv4 with address 172.1.2.18.
May 30 11:01:37 x64-1u avahi-daemon[2022]: Registering new address record for 17
2.1.2.18 on eth2#16.
May 30 11:01:37 x64-1u avahi-daemon[2022]: New relevant interface eth2#17.IPv4 f
or mDNS.
May 30 11:01:37 x64-1u avahi-daemon[2022]: Joining mDNS multicast group on inter
face eth2#17.IPv4 with address 172.1.2.19.
May 30 11:01:37 x64-1u avahi-daemon[2022]: IP_ADD_MEMBERSHIP failed: No buffer s
pace available
May 30 11:01:37 x64-1u avahi-daemon[2022]: Registering new address record for 17
2.1.2.19 on eth2#17.
May 30 11:01:37 x64-1u avahi-daemon[2022]: New relevant interface eth2#18.IPv4 f
or mDNS.
May 30 11:01:37 x64-1u avahi-daemon[2022]: Joining mDNS multicast group on inter
face eth2#18.IPv4 with address 172.1.2.20.
May 30 11:01:37 x64-1u avahi-daemon[2022]: IP_ADD_MEMBERSHIP failed: No buffer s
pace available

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

