From: Pavel Krauz <krauz@cncz.cz>
Subject: capturing VLAN
Date: Fri, 29 Feb 2008 09:56:18 +0100
Message-ID: <200802290956.19093.krauz@cncz.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kwall.cncz.cz ([194.213.192.9]:32100 "EHLO kwall.cncz.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751412AbYB2I4a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Feb 2008 03:56:30 -0500
Received: from asterix.domain.local (unknown [10.3.1.3])
	by kwall.cncz.cz (Postfix) with ESMTP id EA69DBA294
	for <netdev@vger.kernel.org>; Fri, 29 Feb 2008 09:56:27 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi guys
as I see it, capturing packets with VLAN tag over PCAP is simply broken on 2.6 kernel
with the HW acceleration. Applications that need unmodified packets over PCAP in 
promisc mode cannot work when VLAN is present in the traffic.

Is there any chance of getting this fixed? Possibly also for 2.6.18 kernel series which is used by CentOS 5.1?

We want to move to 2.6 kernel, because we use HP servers with lots of memory and need other fixes also. 
Monitoring of VLANs is used by our enterprise customers, it is not just for my fun.
 
Thanks & b.r.
Pavel
