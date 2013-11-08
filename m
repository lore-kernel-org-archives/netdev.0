From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next 0/5] sctp: fix and clean up
Date: Fri, 8 Nov 2013 10:55:05 +0800
Message-ID: <1383879310-22792-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dingtianhong@huawei.com>, <davem@davemloft.net>,
	<linux-sctp@vger.kernel.org>, <netdev@vger.kernel.org>
To: <vyasevich@gmail.com>, <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:32009 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755178Ab3KHCzp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 21:55:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series include: remove the duplicate initialize,
remove else path, fix one lost free, convert func to boolean,
fix some typos.

Wang Weidong (5):
  sctp: remove the duplicate initialize
  sctp: remove the else path
  sctp: if we done update ssnmap, free the new ssnmap
  sctp: convert sctp_peer_needs_update to boolean
  sctp: fix some typos in associola.c

 net/sctp/associola.c | 63 ++++++++++------------------------------------------
 1 file changed, 12 insertions(+), 51 deletions(-)

-- 
1.7.12
