From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH v3 0/2] sctp: fix a problem with net_namespace
Date: Wed, 12 Feb 2014 09:44:42 +0800
Message-ID: <1392169484-8256-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dborkman@redhat.com>, <sergei.shtylyov@cogentembedded.com>,
	<netdev@vger.kernel.org>
To: <nhorman@tuxdriver.com>, <davem@davemloft.net>,
	<vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:41715 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750978AbaBLBpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 20:45:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix a problem with net_namespace, and optimize
the sctp_sysctl_net_register.

v2 -> v3:
  -patch2: add empty line after declaration as potined out by Sergei.

v1 -> v2:
  -patch1: add Neil's ACK.

Wang Weidong (2):
  sctp: fix a missed .data initialization
  sctp: optimize the sctp_sysctl_net_register

 net/sctp/sysctl.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

-- 
1.7.12
