From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [net-2.6 patch 0/2][NETNS] netns fixes
Date: Wed, 30 Apr 2008 23:31:13 +0200
Message-ID: <20080430213113.410541118@localhost.localdomain>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:3548 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755690AbYD3Vdk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2008 17:33:40 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.8/8.13.8) with ESMTP id m3ULXdnm414884
	for <netdev@vger.kernel.org>; Wed, 30 Apr 2008 21:33:39 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3ULXdsx4345874
	for <netdev@vger.kernel.org>; Wed, 30 Apr 2008 23:33:39 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3ULXcuQ029514
	for <netdev@vger.kernel.org>; Wed, 30 Apr 2008 23:33:38 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The two following patches fix bugs related to the network
namespace. The first one fixes a sysfs issue (when using the
sysfs per namespace), and the second one fixes the frag timer
for ipv6 to use the right network namespace.

-- 
