From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH 0/2] sctp: fix a problem with net_namespace
Date: Mon, 27 Jan 2014 11:49:01 +0800
Message-ID: <1390794543-1008-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dborkman@redhat.com>, <netdev@vger.kernel.org>
To: <nhorman@tuxdriver.com>, <davem@davemloft.net>,
	<vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:13555 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753195AbaA0Dtn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jan 2014 22:49:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix a problem with net_namespace, and optimize
the sctp_sysctl_net_register.

Wang Weidong (2):
  sctp: fix a missed .data initialization
  sctp: optimize the sctp_sysctl_net_register

 net/sctp/sysctl.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

-- 
1.7.12
