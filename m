From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 0/3] mlx4 fixes
Date: Wed, 12 Mar 2014 17:16:29 +0200
Message-ID: <1394637392-31104-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:38641 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754327AbaCLPQi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Mar 2014 11:16:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

These short series fixes two bugs related to the vxlan support and 
a missing req module call for the IB driver which is needed to support 
IB/RDMA over Ethernet.

Pathes done over the net tree, commit dd38743 "vlan: Set correct source MAC address 
with TX VLAN offload enabled"

Or.

Or Gerlitz (3):
  net/mlx4_core: Fix wrong dump of the vxlan offloads device capability
  net/mlx4_en: Handle vxlan steering rules for mac address changes
  net/mlx4_core: Load the IB driver when the device supports IBoE

 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    8 ++++++++
 drivers/net/ethernet/mellanox/mlx4/fw.c        |    5 +++--
 drivers/net/ethernet/mellanox/mlx4/main.c      |    2 +-
 3 files changed, 12 insertions(+), 3 deletions(-)
