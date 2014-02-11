From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH v2 0/2] sctp: fix a problem with net_namespace
Date: Tue, 11 Feb 2014 09:49:04 +0800
Message-ID: <1392083346-9420-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dborkman@redhat.com>, <netdev@vger.kernel.org>
To: <nhorman@tuxdriver.com>, <davem@davemloft.net>,
	<vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:42795 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752475AbaBKBtq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 20:49:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix a problem with net_namespace, and optimize
the sctp_sysctl_net_register.

v1 -> v2:
  -patch1: add Neil's ACK.

Wang Weidong (2):
  sctp: fix a missed .data initialization
  sctp: optimize the sctp_sysctl_net_register

 net/sctp/sysctl.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

-- 
1.7.12
