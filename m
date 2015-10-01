From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 0/6] switchdev: bring back switchdev_obj
Date: Thu,  1 Oct 2015 11:03:40 +0200
Message-ID: <1443690226-29833-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:35417 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755189AbbJAJDt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 05:03:49 -0400
Received: by wicge5 with SMTP id ge5so19403214wic.0
        for <netdev@vger.kernel.org>; Thu, 01 Oct 2015 02:03:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Second version of the patch extends to a patchset. Basically this patchset
brings object structure back which disappeared with recent Vivien's patchset.
Also it does a bit of naming changes in order to get the things in line.
Also, object id is put back into object structure.
Thanks to Scott and Vivien for review and suggestions.

Jiri Pirko (6):
  switchdev: rename SWITCHDEV_OBJ_* enum values to SWITCHDEV_OBJ_ID_*
  switchdev: rename SWITCHDEV_ATTR_* enum values to SWITCHDEV_ATTR_ID_*
  switchdev: rename switchdev_obj_vlan to switchdev_obj_port_vlan
  switchdev: rename switchdev_obj_fdb to switchdev_obj_port_fdb
  switchdev: bring back switchdev_obj and use it as a generic object
    param
  switchdev: push object ID back to object structure

 Documentation/networking/switchdev.txt         | 15 +++--
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c |  2 +-
 drivers/net/ethernet/rocker/rocker.c           | 80 ++++++++++++----------
 include/net/switchdev.h                        | 76 ++++++++++++---------
 net/bridge/br_fdb.c                            |  5 +-
 net/bridge/br_stp.c                            |  2 +-
 net/bridge/br_vlan.c                           | 10 +--
 net/core/net-sysfs.c                           |  2 +-
 net/core/rtnetlink.c                           |  2 +-
 net/dsa/slave.c                                | 72 +++++++++++---------
 net/switchdev/switchdev.c                      | 93 ++++++++++++++------------
 11 files changed, 199 insertions(+), 160 deletions(-)

-- 
1.9.3
