From: Sergey Popovich <popovich_sergei@mail.ru>
Subject: [PATCH 0/4] ipv4: small set of fixes
Date: Tue, 21 Jan 2014 13:48:47 +0200
Message-ID: <cover.1390304505.git.popovich_sergei@mail.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback5.mail.ru ([94.100.176.59]:59473 "EHLO
	fallback5.mail.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754099AbaAULtT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 06:49:19 -0500
Received: from smtp11.mail.ru (smtp11.mail.ru [94.100.176.85])
	by fallback5.mail.ru (mPOP.Fallback_MX) with ESMTP id 8ABD610A38E05
	for <netdev@vger.kernel.org>; Tue, 21 Jan 2014 15:49:17 +0400 (MSK)
Received: from [2a01:6d80:103:13::c3ea:4404] (port=42200 helo=tuxracer.localdomain)
	by smtp11.mail.ru with esmtpa (envelope-from <popovich_sergei@mail.ru>)
	id 1W5Zp9-0006Kt-U3
	for netdev@vger.kernel.org; Tue, 21 Jan 2014 15:48:56 +0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In this patch series I present my attempt to address
some issues in IPv4 implementation.

Please take time to review my patches.

Thanks.

Sergey Popovich (4):
  ipv4: don't disable interface if last ipv4 address is removed
  ipv4: fib_semantics: increment fib_info_cnt after fib_info allocation
  ipv4: use SNMP macro assuming softirq context in ip_forward().
  ipv4: mark nexthop as dead when it's subnet becomes unreachable

 net/ipv4/fib_frontend.c  | 14 ++++----------
 net/ipv4/fib_semantics.c | 38 +++++++++++++++++++++-----------------
 net/ipv4/ip_forward.c    |  2 +-
 3 files changed, 26 insertions(+), 28 deletions(-)

-- 
1.8.3.4
