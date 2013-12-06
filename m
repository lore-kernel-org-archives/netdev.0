From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH v3 net-next 0/4] sctp: do some clean ups
Date: Fri, 6 Dec 2013 09:36:26 +0800
Message-ID: <1386293790-19956-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-sctp@vger.kernel.org>
To: <nhorman@tuxdriver.com>, <vyasevich@gmail.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:20711 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970Ab3LFBmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 20:42:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series include: remove the duplicate initialize,
make code simple, convert func to boolean, fix some typos.

v2 -> v3:
  - patch1: add Neil's ACK
  - patch2: add Joe's suggested and Neil's ACK
  - patch3: add Neil's ACK
  - patch4: add Neil's ACK

Wang Weidong (4):
  sctp: remove the duplicate initialize
  sctp: remove the else path
  sctp: convert sctp_peer_needs_update to boolean
  sctp: fix some comments in associola.c

 net/sctp/associola.c | 65 ++++++++--------------------------------------------
 1 file changed, 10 insertions(+), 55 deletions(-)

-- 
1.7.12
