From: Steve Lin <steven.lin1@broadcom.com>
Subject: [PATCH 0/7] Adding permanent config get/set to devlink
Date: Tue, 17 Oct 2017 16:44:22 -0400
Message-ID: <1508273069-40461-1-git-send-email-steven.lin1@broadcom.com>
Cc: jiri@mellanox.com, davem@davemloft.net, michael.chan@broadcom.com,
        linville@tuxdriver.com, gospo@broadcom.com,
        steven.lin1@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rnd-relay.smtp.broadcom.com ([192.19.229.170]:49897 "EHLO
        rnd-relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754553AbdJQUoo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 16:44:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DIFFERENCES FROM RFC:
Implemented most of the changes suggested by Jiri and others.
Thanks for the valuable feedback!

Adds a devlink command for getting & setting permanent
(persistent / NVRAM) device configuration parameters, and
enumerates the parameters as nested devlink attributes.

bnxt driver patches make use of these new devlink cmds/
attributes.

Steve Lin (7):
  devlink: Add permanent config parameter get/set operations
  devlink: Adding NPAR permanent config parameters
  devlink: Adding high level dev perm config params
  devlink: Adding perm config of link settings
  devlink: Adding pre-boot permanent config parameters
  bnxt: Move generic devlink code to new file
  bnxt: Add devlink support for config get/set

 drivers/net/ethernet/broadcom/bnxt/Makefile       |   2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         |   1 +
 drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c | 363 ++++++++++++++++++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.h |  56 ++++
 drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h     | 100 ++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c     |  53 +---
 drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.h     |  37 +--
 include/net/devlink.h                             |   4 +
 include/uapi/linux/devlink.h                      | 113 +++++++
 net/core/devlink.c                                | 300 ++++++++++++++++++
 10 files changed, 944 insertions(+), 85 deletions(-)
 create mode 100644 drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c
 create mode 100644 drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.h

-- 
2.7.4
