From: Wang Weidong <wangweidong1@huawei.com>
Subject: [net-next 0/2] sctp: fix kfree static array pointer in sctp_sysctl_net_unregister
Date: Thu, 8 May 2014 20:55:00 +0800
Message-ID: <1399553702-7960-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-sctp@vger.kernel.org>, <netdev@vger.kernel.org>
To: <davem@davemloft.net>, <vyasevich@gmail.com>,
	<nhorman@tuxdriver.com>, <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:33618 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754159AbaEHMzk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 08:55:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

patch #1 revert the efb842c45("sctp: optimize the sctp_sysctl_net_register")
patch #2 add a checking for sctp_sysctl_net_register

Wang Weidong (2):
  Revert "sctp: optimize the sctp_sysctl_net_register"
  sctp: add a checking for sctp_sysctl_net_register

 net/sctp/sysctl.c | 21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

-- 
1.7.12
