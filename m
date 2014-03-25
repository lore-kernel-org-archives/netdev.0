From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 0/3] slight optimization and avoid spam for bond fast path
Date: Tue, 25 Mar 2014 15:03:54 +0800
Message-ID: <1395731037-4812-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <fubar@us.ibm.com>, <vfalico@redhat.com>, <andy@greyhouse.net>,
	<joe@perches.com>, <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:3102 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751311AbaCYHJ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 03:09:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ding Tianhong (3):
  bonding: slight optimization for bond xmit path
  bonding: ratelimit pr_err() for bond xmit broadcast
  bonding: add ratelimit for bond_arp_rcv()

 drivers/net/bonding/bond_main.c | 29 ++++++++++++++++-------------
 1 file changed, 16 insertions(+), 13 deletions(-)

-- 
1.8.0
