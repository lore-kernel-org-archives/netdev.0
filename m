From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch net-2.6.25 00/10][NETNS][IPV6] make sysctl per namespace - V3
Date: Wed, 09 Jan 2008 17:45:33 +0100
Message-ID: <20080109164533.695191040@localhost.localdomain>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:13701 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752864AbYAIQ7v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 11:59:51 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.8/8.13.8) with ESMTP id m09Gxni0328748
	for <netdev@vger.kernel.org>; Wed, 9 Jan 2008 16:59:49 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m09Gxnt92765014
	for <netdev@vger.kernel.org>; Wed, 9 Jan 2008 17:59:49 +0100
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m09GxnWP013549
	for <netdev@vger.kernel.org>; Wed, 9 Jan 2008 17:59:49 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patchset makes the ipv6 sysctl to handle multiple
network namespaces. Each instance of a network namespace as its own
set of sysctl values, that means the behavior of the ipv6 stack can be
different depending on the sysctl values setup in the different
network namespaces.

Changelog:
	V3 : fixed compilation error when CONFIG_SYSCTL=n,
	     fixed missing initialization when CONFIG_SYSCTL=n

	V2 : make the mld_max_msf variable readonly when we are
	     not in the initial network namespace

	V1 : initial post

-- 
