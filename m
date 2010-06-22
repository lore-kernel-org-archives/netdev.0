From: Ben Greear <greearb@candelatech.com>
Subject: iproute addr flush question
Date: Tue, 22 Jun 2010 15:46:21 -0700
Message-ID: <4C213D3D.8040108@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:45740 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751654Ab0FVWqW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jun 2010 18:46:22 -0400
Received: from [71.117.12.23] (pool-71-117-12-23.sttlwa.dsl-w.verizon.net [71.117.12.23])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id o5MMkLcp029716
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 22 Jun 2010 15:46:21 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is this supposed to work?  I was hoping there was some way to
flush all secondary IPs with a single command:

[root@atom lanforge]# ./local/sbin/ip addr flush dev eth5 secondary
[root@atom lanforge]#  ip addr show dev eth5
8: eth5: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast state DOWN qlen 1000
     link/ether 00:90:0b:13:f4:e9 brd ff:ff:ff:ff:ff:ff
     inet 6.6.6.1/24 brd 6.6.6.255 scope global eth5
     inet 6.6.6.2/24 scope global secondary eth5
     inet 6.6.6.3/24 scope global secondary eth5

This is .34 kernel and .34 matching iproute.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
