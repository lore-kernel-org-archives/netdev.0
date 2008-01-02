From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 0/9][NETNS][IPV6] make sysctl per namespace
Date: Wed, 02 Jan 2008 13:25:48 +0100
Message-ID: <20080102122548.629622062@localhost.localdomain>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([195.212.29.139]:12422 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753176AbYABMgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2008 07:36:32 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate6.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m02CaVGL215186
	for <netdev@vger.kernel.org>; Wed, 2 Jan 2008 12:36:31 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m02CaVd85087256
	for <netdev@vger.kernel.org>; Wed, 2 Jan 2008 12:36:31 GMT
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m02CaEuN007862
	for <netdev@vger.kernel.org>; Wed, 2 Jan 2008 12:36:14 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patchset makes the ipv6 sysctl to handle multiple
network namespaces. Each instance of a network namespace as its own
set of sysctl values, that means the behavior of the ipv6 stack can be
different depending on the sysctl values setup in the different
network namespaces.

-- 
