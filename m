From: Stefan Bauer <sb@plzk.de>
Subject: ip link macvtap interface not processing specific ipv6 multicast
 traffic without promiscuous mode on
Date: Thu, 09 Apr 2015 12:09:27 +0200
Message-ID: <1428574167.2171.32.camel@plzk.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay02.ispgateway.de ([80.67.31.29]:57031 "EHLO
	smtprelay02.ispgateway.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934530AbbDIKNc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 06:13:32 -0400
Received: from [91.47.193.61] (helo=zarafa)
	by smtprelay02.ispgateway.de with esmtpsa (TLSv1.2:DHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.84)
	(envelope-from <sb@plzk.de>)
	id 1Yg9Oq-0007vj-Q1
	for netdev@vger.kernel.org; Thu, 09 Apr 2015 12:09:28 +0200
Received: from s1 (unknown [192.168.0.151])
	by zarafa (Postfix) with ESMTP id A5538220064
	for <netdev@vger.kernel.org>; Thu,  9 Apr 2015 12:09:27 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Linux s1 3.16.0-4-amd64 #1 SMP Debian 3.16.7-ckt7-1 (2015-03-01) x86_64
GNU/Linux
03:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller (rev 10)

The following interface (created by kvm/qemu virtualization)

7: macvtap0@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc
pfifo_fast state UNKNOWN mode DEFAULT group default qlen 500
    link/ether 52:54:00:76:c1:f0 brd ff:ff:ff:ff:ff:ff

is not processing multicast traffic for ipv6 to specific addresses.
My virtual machines get router&prefix correct but can not resolve
addresses - hence are not able to communicate with other machines.

If i put the interface in promiscuous mode the neighbor tables of other
hosts are instantly filled. Without:
2a01:198:200:8350:98ec:1708:c82e:a4fb dev br-lan  INCOMPLETE With:
2a01:198:200:8350:98ec:1708:c82e:a4fb dev br-lan lladdr
52:54:00:8e:b9:eb REACHABLE

Any ideas on this?

Cheers,

Stefan 
