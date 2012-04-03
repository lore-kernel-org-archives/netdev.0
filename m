From: Ben Greear <greearb@candelatech.com>
Subject: /proc/net/dev is funky in 3.3.0
Date: Mon, 02 Apr 2012 21:29:12 -0700
Message-ID: <4F7A7C98.1030103@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:43925 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750756Ab2DCE3N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 00:29:13 -0400
Received: from [50.47.233.138] (50-47-233-138.evrt.wa.frontiernet.net [50.47.233.138])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id q334TCkk018926
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 2 Apr 2012 21:29:13 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not all entries are shown!

[root@lanner-i7 lanforge]# cat /proc/net/dev|grep sta59
[root@lanner-i7 lanforge]# ifconfig sta59
sta59     Link encap:Ethernet  HWaddr 00:95:95:00:00:3C
           inet addr:10.111.9.39  Bcast:10.111.255.255  Mask:255.255.0.0
           inet6 addr: fe80::295:95ff:fe00:3c/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:58103 errors:0 dropped:0 overruns:0 frame:0
           TX packets:26167 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:39494634 (37.6 MiB)  TX bytes:37095540 (35.3 MiB)

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
