From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 0/2] Add accessor to vlan egress map
Date: Wed,  6 Nov 2013 15:37:22 +0200
Message-ID: <1383745044-32575-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, sean.hefty@intel.com,
	eyalpe@mellanox.com, Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:45614 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756544Ab3KFNhd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Nov 2013 08:37:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, Sean,

This series adds on the work done through commits d4a968658c "net/route: export 
symbol ip_tos2prio" and 366cddb40 "IB/rdma_cm: TOS <=> UP mapping for IBoE".

When vlans are used, the IBoE stack needs to inherit the egress map
which is configured on the vlan device. For that end, we provide a
read-only access method and call it from the RDMA-CM.

Or.

Eyal Perry (2):
  net/vlan: Provide access to the vlan egress map
  RDMA/cma: Set IBoE SL (user-priority) by egress map when using vlans

 drivers/infiniband/core/cma.c |   26 +++++++++++++++++++++-----
 include/linux/if_vlan.h       |    9 ++++++++-
 net/8021q/vlan_dev.c          |   18 ++++++++++++------
 3 files changed, 41 insertions(+), 12 deletions(-)
