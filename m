From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: [PATCH net-next v2 4/5] bonding: fix netlink msg size
Date: Fri, 03 Jan 2014 14:28:11 -0800
Message-ID: <20140103222811.1659.80099.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com, jiri@resnulli.us, dingtianhong@huawei.com
To: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:40335 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753362AbaACW2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 17:28:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing space for IFLA_BOND_ARP_IP_TARGET nest header.

Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
---
 drivers/net/bonding/bond_netlink.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 1b4013b..555c783 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -296,6 +296,7 @@ static size_t bond_get_size(const struct net_device *bond_dev)
 		nla_total_size(sizeof(u8)) +	/* IFLA_BOND_USE_CARRIER */
 		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_ARP_INTERVAL */
 						/* IFLA_BOND_ARP_IP_TARGET */
+		nla_total_size(sizeof(struct nlattr)) +
 		nla_total_size(sizeof(u32)) * BOND_MAX_ARP_TARGETS +
 		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_ARP_VALIDATE */
 		nla_total_size(sizeof(u32)) +	/* IFLA_BOND_ARP_ALL_TARGETS */
