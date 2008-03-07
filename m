From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 0/6][NETNS][IPV6] ndisc, tcp, mcast per namespace
Date: Fri, 07 Mar 2008 16:26:38 +0100
Message-ID: <20080307152638.854138982@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([195.212.29.138]:28367 "EHLO
	mtagate5.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760785AbYCGPaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2008 10:30:09 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate5.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m27FU5h4269688
	for <netdev@vger.kernel.org>; Fri, 7 Mar 2008 15:30:05 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m27FU5351921262
	for <netdev@vger.kernel.org>; Fri, 7 Mar 2008 15:30:05 GMT
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m27FU5vW023684
	for <netdev@vger.kernel.org>; Fri, 7 Mar 2008 15:30:05 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patchset makes ndisc, tcp and multicast to be per namespace.
At this point, it is possible to configure a namespace, communicate via
udp6 or tcp6 to the outside world, or run a sshd daemon inside and connect
to it.

-- 
