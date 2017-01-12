From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 0/3] mlxsw: Couple of fixes
Date: Thu, 12 Jan 2017 09:10:36 +0100
Message-ID: <1484208639-1890-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, idosch@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f195.google.com ([209.85.210.195]:36801 "EHLO
        mail-wj0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750860AbdALIKl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 03:10:41 -0500
Received: by mail-wj0-f195.google.com with SMTP id dh1so1002998wjb.3
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 00:10:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Couple of simple fixes from Arkadi and Elad.

Please queue these up for stable. Thanks.

Arkadi Sharshevsky (2):
  mlxsw: spectrum: Fix memory leak at skb reallocation
  mlxsw: switchx2: Fix memory leak at skb reallocation

Elad Raz (1):
  mlxsw: pci: Fix EQE structure definition

 drivers/net/ethernet/mellanox/mlxsw/pci_hw.h   | 8 ++++----
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 1 +
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 1 +
 3 files changed, 6 insertions(+), 4 deletions(-)

-- 
2.7.4
