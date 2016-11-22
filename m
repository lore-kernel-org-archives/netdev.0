From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/2] mlxsw: core: Implement thermal zone
Date: Tue, 22 Nov 2016 11:24:11 +0100
Message-ID: <1479810253-9114-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, cera@cera.cz, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, nogahf@mellanox.com,
        arkadis@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f196.google.com ([209.85.210.196]:34186 "EHLO
        mail-wj0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752902AbcKVKYQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 05:24:16 -0500
Received: by mail-wj0-f196.google.com with SMTP id xy5so5925575wjc.1
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 02:24:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Implement thermal zone for mlxsw based HW.
The first patch is just a register dependency for the second patch.

Ivan Vecera (1):
  mlxsw: core: Implement thermal zone

Jiri Pirko (1):
  mlxsw: reg: Add Management Fan Speed Limit register

 drivers/net/ethernet/mellanox/mlxsw/Kconfig        |   9 +
 drivers/net/ethernet/mellanox/mlxsw/Makefile       |   1 +
 drivers/net/ethernet/mellanox/mlxsw/core.c         |   8 +
 drivers/net/ethernet/mellanox/mlxsw/core.h         |  24 ++
 drivers/net/ethernet/mellanox/mlxsw/core_thermal.c | 442 +++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/reg.h          |  49 +++
 6 files changed, 533 insertions(+)
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/core_thermal.c

-- 
2.7.4
