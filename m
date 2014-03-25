From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 0/2] bonding: slight optimization and avoid spam for bond xmit path
Date: Tue, 25 Mar 2014 17:00:08 +0800
Message-ID: <1395738010-12212-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <fubar@us.ibm.com>, <vfalico@redhat.com>, <andy@greyhouse.net>,
	<joe@perches.com>, <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:17318 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751457AbaCYJIQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 05:08:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v1->v2: Add ratelimit for debugging is not a good idea, it will miss some message
	if the user turns the debugging on, so remove the patch 3.
	use net_err_ratelimited instead of pr_err_ratelimited and use __func__ instead of
	bond_xmit_broadcast().

Ding Tianhong (2):
  bonding: slight optimization for bond xmit path
  bonding: ratelimit pr_err() for bond xmit broadcast

 drivers/net/bonding/bond_main.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

-- 
1.8.0
