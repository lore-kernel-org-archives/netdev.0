From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH 0/4] sctp: do some clean up and fix comments
Date: Fri, 25 Oct 2013 09:50:01 +0800
Message-ID: <1382665805-13952-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dingtianhong@huawei.com>, <linux-sctp@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: <davem@davemloft.net>, <nhorman@tuxdriver.com>,
	<vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:65497 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753807Ab3JYBuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 21:50:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I found: two if statements do the same work, we can merge to one;
kmem_cache_zalloc will reset the memory, no need do the work
which initialize with 0; some spelling errors, then fix them.

Wang Weidong (4):
  sctp: merge two if statements to one
  sctp: remove the repeat initialize with 0
  sctp: fix some comments in associola.c
  sctp: fix comment in chunk.c

 net/sctp/associola.c     |  4 ++--
 net/sctp/auth.c          | 12 ++++--------
 net/sctp/chunk.c         |  2 +-
 net/sctp/sm_make_chunk.c | 29 ++++++++---------------------
 4 files changed, 15 insertions(+), 32 deletions(-)

-- 
1.7.12
