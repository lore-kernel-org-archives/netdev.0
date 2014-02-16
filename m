From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net 0/3] pf_packet fix
Date: Sun, 16 Feb 2014 15:55:19 +0100
Message-ID: <1392562522-15585-1-git-send-email-dborkman@redhat.com>
Cc: brouer@redhat.com, mathias.kretschmer@fokus.fraunhofer.de,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21434 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752290AbaBPOz3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Feb 2014 09:55:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Addressed all feedback from Dave and reworked the original patch
from [1]. Set is intended for 3.14.

Thanks !

  [1] http://patchwork.ozlabs.org/patch/320136/

Daniel Borkmann (3):
  netdevice: add queue selection fallback handler for ndo_select_queue
  netdevice: move netdev_cap_txqueue for shared usage to header
  packet: check for ndo_select_queue during queue selection

 drivers/net/bonding/bond_main.c                 |  2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |  4 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |  6 ++---
 drivers/net/ethernet/lantiq_etop.c              |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c      |  4 ++--
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |  2 +-
 drivers/net/ethernet/tile/tilegx.c              |  2 +-
 drivers/net/team/team.c                         |  2 +-
 drivers/net/tun.c                               |  2 +-
 drivers/net/wireless/mwifiex/main.c             |  2 +-
 drivers/staging/bcm/Bcmnet.c                    |  2 +-
 drivers/staging/netlogic/xlr_net.c              |  2 +-
 drivers/staging/rtl8188eu/os_dep/os_intfs.c     |  2 +-
 include/linux/netdevice.h                       | 29 ++++++++++++++++++++++---
 net/core/flow_dissector.c                       | 20 ++++-------------
 net/mac80211/iface.c                            |  6 +++--
 net/packet/af_packet.c                          | 24 +++++++++++++++++---
 18 files changed, 73 insertions(+), 42 deletions(-)

-- 
1.7.11.7
