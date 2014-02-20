From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net 0/2] tipc: clean up components initialization code
Date: Thu, 20 Feb 2014 11:32:48 +0800
Message-ID: <1392867171-31020-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jon.maloy@ericsson.com>, <Paul.Gortmaker@windriver.com>,
	<erik.hugne@ericsson.com>, <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>, <wangweidong1@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:35917 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752547AbaBTDdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 22:33:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In this series, we will fix a regression issue involved by commit
6e967adf7(tipc: relocate common functions from media to bearer)
But before the issue is fixed, we firstly adjust the process of
components initialization so as to remove all enabled flags from
necessary tipc components. Otherwise, without the change, we also
have to add an extra enabled flag into bearer layer indicating
whether bearer setup is finshed or not.

Ying Xue (2):
  tipc: remove all enabled flags from all tipc components
  tipc: make bearer set up in module insertion stage

 net/tipc/bearer.c     |    7 +++-
 net/tipc/config.c     |    2 +-
 net/tipc/core.c       |  109 ++++++++++++++++++++++++++-----------------------
 net/tipc/core.h       |    1 -
 net/tipc/name_table.c |    3 --
 net/tipc/netlink.c    |    8 ----
 net/tipc/ref.c        |    3 --
 net/tipc/server.c     |    5 ---
 net/tipc/server.h     |    2 -
 net/tipc/socket.c     |    8 ----
 10 files changed, 66 insertions(+), 82 deletions(-)

-- 
1.7.9.5
