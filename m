From: Jean Sacren <sakiwit@gmail.com>
Subject: [PATCH net 0/3] Fix duplicate #include headers
Date: Thu,  7 Aug 2014 06:50:45 -0600
Message-ID: <1407415846-10277-3-git-send-email-sakiwit@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:38093 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757252AbaHGMvE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2014 08:51:04 -0400
Received: by mail-pa0-f42.google.com with SMTP id lf10so5417686pab.29
        for <netdev@vger.kernel.org>; Thu, 07 Aug 2014 05:51:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series fixes duplicate #include headers in the current net
tree.

Jean Sacren (3):
  amd: xgbe: delete duplicate linux/phy.h header
  batman: delete duplicate multicast.h header
  openvswitch: fix duplicate #include headers

 drivers/net/ethernet/amd/xgbe/xgbe-drv.c | 1 -
 net/batman-adv/multicast.c               | 1 -
 net/openvswitch/datapath.c               | 2 --
 3 files changed, 4 deletions(-)
