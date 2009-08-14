From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 00/12] ixgbe/vlan/DCB patch set
Date: Fri, 14 Aug 2009 15:40:49 -0700
Message-ID: <20090814223857.1640.26881.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	gospo@redhat.com
To: davem@davemloft.net
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please merge net-2.6 then apply this set...

---

Vasu Dev (2):
      ixgbe: updates vlan feature flags to enable FCoE offloads on vlan interface
      vlan: adds fcoe offload related net_device_ops and updates fcoe_ddp_xid field

Yi Zou (10):
      ixgbe: Add support for dcbnl_rtnl_ops.setapp/getapp
      dcbnl: Add implementations of dcbnl setapp/getapp commands
      dcbnl: Add netlink attributes for setapp/getapp to dcbnl
      dcbnl: Add support for setapp/getapp to netdev dcbnl_rtnl_ops
      dcbnl: Add support for setapp/getapp commands to dcbnl
      ixgbe: Add support for the net_device_ops.ndo_fcoe_control to 82599
      vlan: Add support for net_devices_ops.ndo_fcoe_control to VLAN
      net: Add ndo_fcoe_control to net_device_ops
      ixgbe: Add support for NETIF_F_FCOE_MTU to 82599 devices
      net: Add NETIF_F_FCOE_MTU to indicate support for a different MTU for FCoE


 drivers/net/ixgbe/ixgbe.h        |    5 +
 drivers/net/ixgbe/ixgbe_dcb_nl.c |   83 ++++++++++++-----
 drivers/net/ixgbe/ixgbe_fcoe.c   |  184 ++++++++++++++++++++++++++++++++++++++
 drivers/net/ixgbe/ixgbe_fcoe.h   |    4 +
 drivers/net/ixgbe/ixgbe_main.c   |    9 +-
 include/linux/dcbnl.h            |   18 ++++
 include/linux/netdevice.h        |    5 +
 include/net/dcbnl.h              |    2 
 net/8021q/vlan.c                 |    3 +
 net/8021q/vlan_dev.c             |   52 +++++++++++
 net/dcb/dcbnl.c                  |  130 +++++++++++++++++++++++++++
 11 files changed, 469 insertions(+), 26 deletions(-)

-- 
Cheers,
Jeff
