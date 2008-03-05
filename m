From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 0/9][NETNS][IPV6] make addrconf and icmp per namespace
Date: Wed, 05 Mar 2008 18:56:49 +0100
Message-ID: <20080305175649.348451657@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:35620 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751733AbYCESB6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 13:01:58 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.13.8/8.13.8) with ESMTP id m25I1vvg027668
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 18:01:57 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m25I1vvN1871924
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 19:01:57 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m25I1vpf005882
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 18:01:57 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patchset makes the different part of ipv6 to take
into account the namespaces. On top of that, addrconf and icmp
are now aware how to use the namespaces too. So we can move an
interface inside the namespace and set ip up to have an ipv6
address autoconfigured and be able to ping it.

ndisc will come very soon ... :)

-- 
