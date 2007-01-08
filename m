From: Ben Greear <greearb@candelatech.com>
Subject: Question on advanced routing and/or virtual routers.
Date: Mon, 08 Jan 2007 09:08:08 -0800
Message-ID: <45A27A78.8010200@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:45356 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750918AbXAHRGO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jan 2007 12:06:14 -0500
Received: from [71.112.210.101] (pool-71-112-210-101.sttlwa.dsl-w.verizon.net [71.112.210.101])
	(authenticated bits=0)
	by ns2.lanforge.com (8.13.4/8.13.4) with ESMTP id l08H6Crt022637
	for <netdev@vger.kernel.org>; Mon, 8 Jan 2007 09:06:13 -0800
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

I am curious if a single machine can be made to look like several 
routers.  Please consider the following
configuration:

Linux Router-A has 4 ethernet interfaces.  PC-A is connected to eth0 and 
has IP 192.168.0.2.
eth0 on Router-A has IP 192.168.0.1/24
eth1 has IP 192.168.1.1/24, and eth1 is connected directly to eth2
eth2 has IP 192.168.2.1/24
eth3 is connected 'upstream' and has IP 192.168.3.1/24

I would like for PC-A to be able to ping 192.168.0.1 and 192.168.1.1 as 
normal.
The part I'm not sure how to make work is that I want to be able to ping 
192.168.2.1 and
have the packet route out of eth1 and into eth2 (PC-A -> eth0 -> eth1 -> 
eth2), and have the return packet follow the
eth2 -> eth1 -> eth0 -> PC-A path.  A trace-route from PC-A should show 
each of these hops (or, at least eth0 and eth2.)

The eventual goal is to have arbitrary numbers of 'routers' in a single 
Linux machine for emulation
purposes.

I was thinking that I might could accomplish this using multiple routing 
tables and perhaps
specific subnet routes for each each virtual router, specifying which 
interface the packets should
leave in order to find the next hop.

Has anyone tried something similar to this or have ideas for how to best 
proceed?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


