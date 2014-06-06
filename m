From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/2] net: couple of facelifts around ethtool speed and duplex values
Date: Fri,  6 Jun 2014 14:16:59 +0200
Message-ID: <1402057021-12867-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:53652 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751646AbaFFMRG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 08:17:06 -0400
Received: by mail-wi0-f175.google.com with SMTP id f8so851433wiw.14
        for <netdev@vger.kernel.org>; Fri, 06 Jun 2014 05:17:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko (2):
  net: use SPEED_UNKNOWN and DUPLEX_UNKNOWN when appropriate
  net: use ethtool_cmd_speed_set helper to set ethtool speed value

 drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c    |  4 ++--
 drivers/net/ethernet/atheros/atl1e/atl1e_ethtool.c    |  4 ++--
 drivers/net/ethernet/atheros/atlx/atl1.c              |  4 ++--
 drivers/net/ethernet/atheros/atlx/atl2.c              |  4 ++--
 drivers/net/ethernet/broadcom/bnx2.c                  |  4 ++--
 drivers/net/ethernet/brocade/bna/bnad_ethtool.c       |  4 ++--
 drivers/net/ethernet/chelsio/cxgb/cxgb2.c             |  4 ++--
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c       |  4 ++--
 drivers/net/ethernet/cisco/enic/enic_ethtool.c        |  4 ++--
 drivers/net/ethernet/dec/tulip/uli526x.c              |  4 ++--
 drivers/net/ethernet/dlink/dl2k.c                     |  4 ++--
 drivers/net/ethernet/ibm/ehea/ehea_ethtool.c          |  4 ++--
 drivers/net/ethernet/intel/e1000/e1000_ethtool.c      |  4 ++--
 drivers/net/ethernet/intel/e1000e/ethtool.c           |  4 ++--
 drivers/net/ethernet/intel/igb/igb_ethtool.c          | 14 ++++++++------
 drivers/net/ethernet/intel/igbvf/ethtool.c            |  4 ++--
 drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c        |  4 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c      |  4 ++--
 drivers/net/ethernet/intel/ixgbevf/ethtool.c          |  4 ++--
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c       |  4 ++--
 drivers/net/ethernet/neterion/s2io.c                  |  4 ++--
 drivers/net/ethernet/neterion/vxge/vxge-ethtool.c     |  4 ++--
 drivers/net/ethernet/nvidia/forcedeth.c               |  4 ++--
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c   |  2 +-
 drivers/net/ntb_netdev.c                              |  1 -
 drivers/net/vmxnet3/vmxnet3_ethtool.c                 |  4 ++--
 drivers/s390/net/qeth_core_main.c                     | 19 +++++++++++--------
 27 files changed, 66 insertions(+), 62 deletions(-)

-- 
1.9.0
