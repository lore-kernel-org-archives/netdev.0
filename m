From: Dave Jones <davej@redhat.com>
Subject: E1000 stopped transmitting in rc3.
Date: Thu, 27 Apr 2006 20:13:52 -0400
Message-ID: <20060428001352.GA3319@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:21693 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751736AbWD1ANy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 20:13:54 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id k3S0DsZN017390
	for <netdev@vger.kernel.org>; Thu, 27 Apr 2006 20:13:54 -0400
Received: from nwo.kernelslacker.org (vpn83-146.boston.redhat.com [172.16.83.146])
	by int-mx1.corp.redhat.com (8.12.11.20060308/8.11.6) with ESMTP id k3S0DrQZ001390
	for <netdev@vger.kernel.org>; Thu, 27 Apr 2006 20:13:53 -0400
Received: from nwo.kernelslacker.org (localhost.localdomain [127.0.0.1])
	by nwo.kernelslacker.org (8.13.6/8.13.5) with ESMTP id k3S0DqSb005386
	for <netdev@vger.kernel.org>; Thu, 27 Apr 2006 20:13:52 -0400
Received: (from davej@localhost)
	by nwo.kernelslacker.org (8.13.6/8.13.6/Submit) id k3S0DqRQ005385
	for netdev@vger.kernel.org; Thu, 27 Apr 2006 20:13:52 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With 2.6.17-rc3, my E1000 won't get a dhcp lease.
Looking at tcpdump and ifconfig output, it's easy to see why.
It's recieving packets, but the packets transmitted field
of ifconfig never increases.

The last version I have built that worked ok was 2.6.17rc2-git3

NIC is ..
03:0e.0 Ethernet controller: Intel Corporation 82545GM Gigabit Ethernet Controller (rev 04)
(8086:1026)

		Dave

-- 
http://www.codemonkey.org.uk
