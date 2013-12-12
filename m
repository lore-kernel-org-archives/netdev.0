From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next 0/4] tipc: do some clean up
Date: Thu, 12 Dec 2013 09:36:38 +0800
Message-ID: <1386812202-11956-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <erik.hugne@ericsson.com>, <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>
To: <jon.maloy@ericsson.com>, <allan.stephens@windriver.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:19892 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750894Ab3LLBg4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 20:36:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series do some small clean up in tipc.

Wang Weidong (4):
  tipc: remove unnecessary variables and conditions
  tipc: kill unnecessary goto's
  tipc: Use <linux/uaccess.h> instead of <asm/uaccess.h>
  tipc: change lock_sock order in connect()

 net/tipc/core.h       |  2 +-
 net/tipc/name_table.c |  3 +--
 net/tipc/port.c       |  9 +++------
 net/tipc/socket.c     | 33 ++++++++++++---------------------
 4 files changed, 17 insertions(+), 30 deletions(-)

-- 
1.7.12
