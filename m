From: Lance Richardson <lrichard@redhat.com>
Subject: [PATCH net 0/3] ipv4: fix various issues reported by sparse
Date: Wed,  6 Jan 2016 17:22:44 -0500
Message-ID: <1452118967-32123-1-git-send-email-lrichard@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44313 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752483AbcAFWWs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2016 17:22:48 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (Postfix) with ESMTPS id 005158C1B0
	for <netdev@vger.kernel.org>; Wed,  6 Jan 2016 22:22:47 +0000 (UTC)
Received: from dhcp129-205.rdu.redhat.com (dhcp129-10.rdu.redhat.com [10.13.129.10])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u06MMlZn005846
	for <netdev@vger.kernel.org>; Wed, 6 Jan 2016 17:22:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This trivial patch series addresses a number of endianness- and
lock-related issues reported by sparse.

Lance Richardson (3):
  ipv4: fix endianness warnings in ip_tunnel_core.c
  ipv4: eliminate endianness warnings in ip_fib.h
  ipv4: eliminate lock count warnings in ping.c

 include/net/ip_fib.h      |  3 ++-
 net/ipv4/ip_tunnel_core.c | 16 ++++++++--------
 net/ipv4/ping.c           |  2 ++
 3 files changed, 12 insertions(+), 9 deletions(-)

-- 
2.5.0
