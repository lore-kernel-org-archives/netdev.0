From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: interprocess communication with netlinks
Date: Thu, 07 May 2009 18:00:46 +0200
Message-ID: <4A0305AE.4000203@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:43510 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760392AbZEGQAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 12:00:48 -0400
Received: from d06nrmr1806.portsmouth.uk.ibm.com (d06nrmr1806.portsmouth.uk.ibm.com [9.149.39.193])
	by mtagate4.uk.ibm.com (8.14.3/8.13.8) with ESMTP id n47G0ljp219192
	for <netdev@vger.kernel.org>; Thu, 7 May 2009 16:00:47 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1806.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n47G0lHc3297332
	for <netdev@vger.kernel.org>; Thu, 7 May 2009 17:00:47 +0100
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n47G0kKx028584
	for <netdev@vger.kernel.org>; Thu, 7 May 2009 17:00:47 +0100
Received: from smtp.lab.toulouse-stg.fr.ibm.com (smtp.lab.toulouse-stg.fr.ibm.com [9.101.4.108])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id n47G0kEH028579
	for <netdev@vger.kernel.org>; Thu, 7 May 2009 17:00:46 +0100
Received: from mai-009101017029.toulouse-stg.fr.ibm.com (dhcp0.lab.toulouse-stg.fr.ibm.com [9.101.4.200])
	by smtp.lab.toulouse-stg.fr.ibm.com (Postfix) with ESMTP id 691CA2A8051
	for <netdev@vger.kernel.org>; Thu,  7 May 2009 18:00:46 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi netdev gurus !

I am trying to make several processes to communicate via the netlink 
protocol.

I saw a discussion around the AF_IPN (inter process communication) 
protocol and it seems the same can be done with the AF_NETLINK protocol 
with minor modifications in the kernel. Were these modifications done ?

I am trying to use multicast between several processes, for notification.

What protocol should I use to create the socket ?

    fd = socket(PF_NETLINK, SOCK_RAW,  ???);

I was not able to find any suitable pointer to explain how to do that, 
so I blindly tried several combinations but I am afraid to interact with 
the other netlink protocols when using a multicast group, especially 
when there are other applications like avahi-daemon or "ip monitor all".

Does anyone have a pointer to a documentation (not the redhat one, pls), 
or some clues ?

Thanks in advance.
  -- Daniel
