From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH v6 0/3] sctp: check the rto_min and rto_max
Date: Tue, 10 Dec 2013 10:46:34 +0800
Message-ID: <1386643597-22156-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dborkman@redhat.com>, <netdev@vger.kernel.org>,
	<linux-sctp@vger.kernel.org>
To: <vyasevich@gmail.com>, <nhorman@tuxdriver.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:22256 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751919Ab3LJCrl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 21:47:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v5 -> v6
  -patch1: do rto_min/max socket option handling in its own patch, and
   fix the check of rto_min/max.
  -patch2: do rto_min/max sysctl handling in its own patch.
  -patch3: add Suggested-by Daniel.

Wang Weidong (3):
  sctp: check the rto_min and rto_max in setsockopt
  sctp: add check rto_min and rto_max in sysctl
  sctp: fix up a spacing

 net/sctp/socket.c | 32 +++++++++++++++--------
 net/sctp/sysctl.c | 76 ++++++++++++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 89 insertions(+), 19 deletions(-)

-- 
1.7.12
