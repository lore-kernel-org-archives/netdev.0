From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Default offload settings in Ethernet drivers
Date: Thu, 11 Dec 2008 19:41:31 +0100
Message-ID: <49415EDB.3030006@computer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay010.isp.belgacom.be ([195.238.6.177]:24066 "EHLO
	mailrelay010.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755952AbYLKSls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 13:41:48 -0500
Received: from [192.168.1.4] (athloroad.xperim.be [192.168.1.4])
	(authenticated bits=0)
	by via.xperim.be (8.14.1/8.14.1/Debian-8ubuntu1) with ESMTP id mBBIfYqf025140
	for <netdev@vger.kernel.org>; Thu, 11 Dec 2008 19:41:36 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

A discussion recently took place on the power mailing list on the 
subject of the impact of (hardware-assisted) offload functions on the 
power efficiency of the overall system.

The discussion was brought on by me noticing that not all drivers enable 
  all of their offload features by default (case in point: r8169).

Although the discussion may not be complete, early indications are that:

1. Hardware-assisted offloads improve power efficiency unless 
implemented in a separate CPU (TOE / Total Offloading);

2. It would probably be a good idea to enable hardware-assisted offloads 
other than TOE by default given the above.

I would therefore like to sollicit views here:

1. Would changing default offload settings in Ethernet drivers help to 
save the planet?

2. Which offload settings does it make sense to enable by default?


Thanks, Jan
