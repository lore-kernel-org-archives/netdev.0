From: Ben Greear <greearb@candelatech.com>
Subject: VLAN test cases in 2.6.38.7
Date: Tue, 24 May 2011 11:49:58 -0700
Message-ID: <4DDBFDD6.4060903@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:56315 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752696Ab1EXSt7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 14:49:59 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id p4OInwvT002563
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 24 May 2011 11:49:59 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I wrote a simple bridge that uses packet sockets to read/write
from network devices.  I'll upload this code somewhere when
I get it a bit more presentable.

Machine info:

Linux lf0300-demo 2.6.38.7+ #14 SMP Mon May 23 10:31:45 PDT 2011 i686 i686 i386 GNU/Linux

Interface A: eth1
driver: igb
version: 3.0.19
firmware-version: 1.2-1
bus-info: 0000:01:00.0

Interface B: eth3:
driver: igb
version: 3.0.19
firmware-version: 1.2-1
bus-info: 0000:01:00.1


If no vlans are on eth1 and eth3, then it bridges fine, with vlan
headers inline.  But, if you add a VLAN to eth1, it stops working,
probably because pkt tag is then un-stripped.  I was generating on
vlan 7, and created vlan 9, btw.

I'll see if I can figure out how to use aux-data next...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

