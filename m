From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next v2 0/2] tipc: do some fixups
Date: Wed, 25 Dec 2013 10:11:11 +0800
Message-ID: <1387937473-5804-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <David.Laight@ACULAB.COM>, <netdev@vger.kernel.org>
To: <jeremy.kalman@windriver.com>, <jon.maloy@ericsson.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:21080 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751166Ab3LYCLj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Dec 2013 21:11:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

in commit 0cee6bbe06f ("tipc: remove unnecessary variables and conditions")
and commit 3b8401fe9d ("tipc: kill unnecessary goto's") not make the
code best. so fix them, as suggested by David Laight.

v1 -> v2:
  patch1 and patch2 fix the problem "Referring commit purely by
  SHA1 ID is ambiguous" which pointed out by David.

Wang Weidong (2):
  tipc: make the code look more better
  tipc: make the code look more readability

 net/tipc/port.c   | 13 ++++++-------
 net/tipc/socket.c |  7 ++-----
 2 files changed, 8 insertions(+), 12 deletions(-)

-- 
1.7.12
