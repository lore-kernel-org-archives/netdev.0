From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V1 net-next 0/3] Mellanox Core and Ethernet driver updates 2013-04-07
Date: Sun,  7 Apr 2013 16:44:05 +0300
Message-ID: <1365342248-31901-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, sagig@mellanox.com,
	john.r.fastabend@intel.com, Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog119.obsmtp.com ([207.126.144.147]:32864 "EHLO
	eu1sys200aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933632Ab3DGNoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Apr 2013 09:44:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Here's V1 of this batch of mlx4 driver updates for 3.10, mostly DCB related. 

Series done against the net-next tree as of commit a210576c "Merge 
git://git.kernel.org/pub/scm/linux/kernel/git/davem/net"

changes from V0: 

  - in patch #2 advertize getdcbx/setdcbx callbacks also for devices that support only PFC

  - per feedback from John, dropeed patch #3 which turned to be work-around for user space 
    bug in open-lldp. John posted a user space patch to fix the bug

  - per feedback from John, added small a patch under which we advertize DCB_CAP_DCBX_HOST in getdcbx

Or.


Or Gerlitz (3):
  net/mlx4_core: Added proper description for two device capabilities
  net/mlx4_en: Enable DCB ETS ops only when supported by the firmware
  net/mlx4_en: Advertize DCB_CAP_DCBX_HOST in getdcbx

 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c |   10 +++++++++-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   10 ++++++++--
 drivers/net/ethernet/mellanox/mlx4/fw.c        |    4 +++-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |    1 +
 include/linux/mlx4/device.h                    |    1 +
 5 files changed, 22 insertions(+), 4 deletions(-)
