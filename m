From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 0/9][NETNS][IPV6] make sysctl per namespace
Date: Fri, 04 Jan 2008 12:12:26 +0100
Message-ID: <20080104111226.776105484@localhost.localdomain>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:43207 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751146AbYADLWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2008 06:22:43 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.8/8.13.8) with ESMTP id m04BMe9r360014
	for <netdev@vger.kernel.org>; Fri, 4 Jan 2008 11:22:40 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m04BMeQA2621652
	for <netdev@vger.kernel.org>; Fri, 4 Jan 2008 12:22:40 +0100
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m04BMews014954
	for <netdev@vger.kernel.org>; Fri, 4 Jan 2008 12:22:40 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patchset makes the ipv6 sysctl to handle multiple
network namespaces. Each instance of a network namespace as its own
set of sysctl values, that means the behavior of the ipv6 stack can be
different depending on the sysctl values setup in the different
network namespaces.

Changelog:

	V2 : make the mld_max_msf variable readonly when we are
	     not in the initial network namespace

	V1 : initial post

-- 
