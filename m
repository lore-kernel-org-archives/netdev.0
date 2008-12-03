From: James Courtier-Dutton <James@superbug.co.uk>
Subject: Request for a Down alarm counter
Date: Wed, 03 Dec 2008 10:51:50 +0000
Message-ID: <493664C6.8020405@superbug.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from anchor-post-3.mail.demon.net ([195.173.77.134]:48750 "EHLO
	anchor-post-3.mail.demon.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751543AbYLCLIs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2008 06:08:48 -0500
Received: from superbug.demon.co.uk ([80.176.146.252] helo=[192.168.0.10])
	by anchor-post-3.mail.demon.net with esmtp (Exim 4.69)
	id 1L7pKh-0004tY-n7
	for netdev@vger.kernel.org; Wed, 03 Dec 2008 10:51:51 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

when using the "ifconfig" command, one can output various stats.
lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:674053 errors:0 dropped:0 overruns:0 frame:0
          TX packets:674053 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:190599106 (181.7 MiB)  TX bytes:190599106 (181.7 MiB)


I would like to add a "Alarms: 10" counter.
This would count the number of times the network link goes down.
This is particularly useful when diagnosing intermittent faults.
This would also be particularly useful for wireless Ethernet links.

This sort of information is normally available for T1 and E1 type links,
so why not introduce it for Ethernet links.

Kind Regards

James
