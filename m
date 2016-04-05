From: Liping Zhang <zlpnobody@163.com>
Subject: [PATCH V2 0/2] net: socket: return a proper error code when source address becomes nonlocal
Date: Tue,  5 Apr 2016 22:19:44 +0800
Message-ID: <1459865986-18271-1-git-send-email-zlpnobody@163.com>
Cc: netdev@vger.kernel.org, Liping Zhang <liping.zhang@spreadtrum.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-18.163.com ([220.181.12.18]:55539 "EHLO m12-18.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756853AbcDEOUb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 10:20:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <liping.zhang@spreadtrum.com>

This patch version 2 spilt the original patch into 2 patches, because it fix
two separate problems actually.

Liping Zhang (2):
  net: socket: return EADDRNOTAVAIL when source address becomes
    nonlocal
  net: socket: return EADDRNOTAVAIL when IPV6_PKTINFO's ipi6_addr is
    not available

 net/ipv4/route.c    |    6 ++++--
 net/ipv6/datagram.c |    2 +-
 2 files changed, 5 insertions(+), 3 deletions(-)

-- 
1.7.9.5
