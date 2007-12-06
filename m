From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 0/6] ipv6 - ipv6 routing initialization
Date: Thu, 06 Dec 2007 14:53:29 +0100
Message-ID: <20071206135329.598202596@ICON-9-164-138-215.megacenter.de.ibm.com>
Cc: yoshfuji@linux-ipv6.org, pekkas@netcore.fi, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:44049 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752703AbXLFOGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 09:06:20 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate8.de.ibm.com (8.13.8/8.13.8) with ESMTP id lB6E6Gnm387308
	for <netdev@vger.kernel.org>; Thu, 6 Dec 2007 14:06:17 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lB6E6CJe4219106
	for <netdev@vger.kernel.org>; Thu, 6 Dec 2007 14:06:13 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lB6E5rLS012416
	for <netdev@vger.kernel.org>; Thu, 6 Dec 2007 14:05:53 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset provides modifications around the routes initialization
for ipv6. Actually the init functions does not return an error code
so the protocol can not be notified that there were an error while 
initializing the routing subsystems.

The patchset make the init functions to return an error code, so the ipv6
can safely handle the error and fail gracefully.

The error code can also let to catch the kmem_cache_creation failure without
doing a radical panic. That's allow just to fail to load the ipv6 module without 
crashing down the machine.

-- 
