From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next 0/6] tipc: do some clean ups
Date: Fri, 6 Dec 2013 14:23:36 +0800
Message-ID: <1386311022-11176-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>
To: <jon.maloy@ericsson.com>, <allan.stephens@windriver.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:4807 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753787Ab3LFGX5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 01:23:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series do some small clean up in tipc. almost of them 
just code simplification, no functional changes.

Wang Weidong (6):
  tipc: add link_kfree_skbuff helper function
  tipc: remove the unnecessary variable
  tipc: use a same goto path
  tipc: Use <linux/uaccess.h> instead of <asm/uaccess.h>
  tipc: change lock_sock order in connect()
  tipc: separate the check nseq and sseq allocate failed

 net/tipc/core.h       |  2 +-
 net/tipc/link.c       | 58 +++++++++++++++++----------------------------------
 net/tipc/name_table.c | 14 ++++++++-----
 net/tipc/port.c       |  9 +++-----
 net/tipc/socket.c     | 33 +++++++++++------------------
 5 files changed, 44 insertions(+), 72 deletions(-)

-- 
1.7.12
