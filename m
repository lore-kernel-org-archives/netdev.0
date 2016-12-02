From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next 0/5] use reset to set headers
Date: Fri,  2 Dec 2016 09:51:02 +0800
Message-ID: <1480643467-4420-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta2.chinamobile.com ([221.176.66.80]:19749 "EHLO
        cmccmta2.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754577AbcLBBvS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 20:51:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch serial replace 'set' function to 'reset', since the offset is zero.
It's not necessary to use set, reset function is straightforward, and will 
remove the unnecessary add operation in set function.  

Zhang Shengju (5):
  qede: use reset to set network header
  bnx2x: use reset to set network header
  mlx4: use reset to set mac header
  iwlwifi: use reset to set transport header
  staging: wilc1000: use reset to set mac header

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  | 2 +-
 drivers/net/ethernet/mellanox/mlx4/en_selftest.c | 2 +-
 drivers/net/ethernet/qlogic/qede/qede_main.c     | 2 +-
 drivers/net/wireless/intel/iwlwifi/pcie/tx.c     | 2 +-
 drivers/staging/wilc1000/linux_mon.c             | 4 ++--
 5 files changed, 6 insertions(+), 6 deletions(-)

-- 
1.8.3.1
