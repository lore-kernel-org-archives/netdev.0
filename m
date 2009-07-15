From: Ben Greear <greearb@candelatech.com>
Subject: Determine veth peer device?
Date: Wed, 15 Jul 2009 16:55:10 -0700
Message-ID: <4A5E6C5E.1070808@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:40266 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756167AbZGOXzK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2009 19:55:10 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id n6FNtA34004076
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 15 Jul 2009 16:55:10 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is there a way to determine the peer device for a
veth interface in user-space?

I didn't see anything obvious printed in 'ip link show'

[root@i7-1qc-1 ~]# ip link show dev veth0
7: veth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
     link/ether 72:2e:4d:74:5b:a6 brd ff:ff:ff:ff:ff:ff

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

