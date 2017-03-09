From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/2] mlxsw: spectrum: Add support for VLAN offload for cls_flower
Date: Thu,  9 Mar 2017 09:25:18 +0100
Message-ID: <1489047920-3557-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, petrm@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:36248 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752704AbdCIIZY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 03:25:24 -0500
Received: by mail-wr0-f194.google.com with SMTP id l37so6919380wrc.3
        for <netdev@vger.kernel.org>; Thu, 09 Mar 2017 00:25:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This patchset adds support to offload VLAN modify TC action and adds support
to offload cls_flower rules that include VID and PCP matching.

Petr Machata (2):
  mlxsw: spectrum: Add support for vlan modify TC action
  mlxsw: spectrum: Add support for flower matches on VLAN ID, PCP

 .../mellanox/mlxsw/core_acl_flex_actions.c         | 83 ++++++++++++++++++++++
 .../mellanox/mlxsw/core_acl_flex_actions.h         |  2 +
 .../ethernet/mellanox/mlxsw/core_acl_flex_keys.h   |  6 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  3 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c | 29 ++++++++
 .../mellanox/mlxsw/spectrum_acl_flex_keys.h        |  6 ++
 .../ethernet/mellanox/mlxsw/spectrum_acl_tcam.c    |  2 +
 .../net/ethernet/mellanox/mlxsw/spectrum_flower.c  | 34 ++++++++-
 include/net/tc_act/tc_vlan.h                       |  5 ++
 9 files changed, 168 insertions(+), 2 deletions(-)

-- 
2.7.4
