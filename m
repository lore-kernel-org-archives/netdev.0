From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 0/2] vlan: fix ns issue and slight optimization
Date: Fri, 28 Feb 2014 15:50:37 +0800
Message-ID: <1393573839-32316-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <joe@perches.com>, <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <kaber@trash.net>, <julia.lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:57093 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750873AbaB1HvI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 02:51:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ding Tianhong (2):
  vlan: don't allow vlan device to move between network namespaces
  vlan: use ether_addr_equal_64bits to instead of ether_addr_equal

 net/8021q/vlan.c      | 10 +++++-----
 net/8021q/vlan_core.c |  2 +-
 net/8021q/vlan_dev.c  | 13 ++++++++-----
 3 files changed, 14 insertions(+), 11 deletions(-)

-- 
1.8.0
