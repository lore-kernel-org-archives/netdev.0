From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH 0/2] ipv6: fix the missing copies when memcpy ipv6_pinfo
Date: Tue, 19 Nov 2013 10:47:25 +0800
Message-ID: <1384829247-8624-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dccp@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-sctp@vger.kernel.org>, <dingtianhong@huawei.com>
To: <davem@davemloft.net>, <gerrit@erg.abdn.ac.uk>,
	<kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<vyasevich@gmail.com>, <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:9483 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751421Ab3KSCsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 21:48:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series include: add the helper function, use it when
memcpy struct ipv6_pinfo.

Wang Weidong (2):
  ipv6: add helper function for copy addrs from old sock
  ipv6: use sk_v6_copy_addrs when memcpy struct ipv6_pinfo

 include/net/sock.h  | 6 ++++++
 net/dccp/ipv6.c     | 4 ++++
 net/ipv6/tcp_ipv6.c | 4 ++++
 net/sctp/ipv6.c     | 4 ++++
 4 files changed, 18 insertions(+)

-- 
1.7.12
