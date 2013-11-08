From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next v2 0/4] sctp: do some clean ups
Date: Fri, 8 Nov 2013 14:17:47 +0800
Message-ID: <1383891471-20892-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <dingtianhong@huawei.com>,
	<linux-sctp@vger.kernel.org>, <netdev@vger.kernel.org>
To: <vyasevich@gmail.com>, <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:37246 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751452Ab3KHGSw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 01:18:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series include: remove the duplicate initialize,                                                                                                
make code simple, convert func to boolean, fix some typos.

v1 -> v2:
  - patch2: make the code more simplification, as suggested
    by Joe Perches.

Wang Weidong (4):
  sctp: remove the duplicate initialize
  sctp: remove the else path
  sctp: convert sctp_peer_needs_update to boolean
  sctp: fix some comments in associola.c

 net/sctp/associola.c | 65 ++++++++--------------------------------------------
 1 file changed, 10 insertions(+), 55 deletions(-)

-- 
1.7.12
