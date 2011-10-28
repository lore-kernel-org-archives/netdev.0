From: Ben Greear <greearb@candelatech.com>
Subject: Cannot remove GRE interface in wireless-next (3.0.0 based)
Date: Fri, 28 Oct 2011 14:59:23 -0700
Message-ID: <4EAB25BB.6070607@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:43110 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755777Ab1J1V7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2011 17:59:24 -0400
Received: from [192.168.100.111] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id p9SLxNiY008745
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 28 Oct 2011 14:59:24 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm not sure if wireless-next is up to date with the rest of the
kernel (it sort of seems not based on the kernel version), but
thought I'd report this GRE issue:

[root@lec2010-ath9k-1 lanforge]# ip tunnel del gre0
ioctl: Operation not permitted
[root@lec2010-ath9k-1 lanforge]# ifconfig gre0
gre0      Link encap:UNSPEC  HWaddr 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00
           NOARP MULTICAST  MTU:1476  Metric:1
           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)

I'll dig into it further if I get a chance, but stuck in the
wireless stack at the moment...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
