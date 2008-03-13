From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [net-2.6.26 patch 0/6][NETNS][IPV6] handling more proc per namespace
Date: Thu, 13 Mar 2008 12:46:09 +0100
Message-ID: <20080313114609.176640638@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net, den@openvz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:57652 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752049AbYCMLu4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2008 07:50:56 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.8/8.13.8) with ESMTP id m2DBoumV114998
	for <netdev@vger.kernel.org>; Thu, 13 Mar 2008 11:50:56 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2DBot6c1851540
	for <netdev@vger.kernel.org>; Thu, 13 Mar 2008 12:50:55 +0100
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2DBosCh020167
	for <netdev@vger.kernel.org>; Thu, 13 Mar 2008 12:50:55 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset makes tcp6/udp6 to have their proc files to be per
namespace. This is useful for netstat :)  
It fixes also a compilation warning for multicast.

-- 
