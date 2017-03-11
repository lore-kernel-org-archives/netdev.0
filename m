From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/9] mlxsw: Add support for TC flower offload statistics
Date: Sat, 11 Mar 2017 09:42:50 +0100
Message-ID: <1489221779-3807-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, mlxsw@mellanox.com,
        idosch@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35906 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750939AbdCKInD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Mar 2017 03:43:03 -0500
Received: by mail-wm0-f65.google.com with SMTP id v190so2232511wme.3
        for <netdev@vger.kernel.org>; Sat, 11 Mar 2017 00:43:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Arkadi says:
This patchset adds support for retrieving TC flower statistics for
offloaded rules, which includes packets count, bytes count and last used
time stamp. Currently The statistics are gathered on a per-rule basis.

This patchset also includes generic allocator for counters.

Arkadi Sharshevsky (9):
  mlxsw: spectrum: Add support for counter allocator
  mlxsw: reg: Add Monitoring General Purpose Counter Set register
  mlxsw: spectrum: Add support for generic flow counter allocation
  mlxsw: spectrum_acl_tcam: Add support for retrieving TCAM entry
    activity
  mlxsw: spectrum: Add support for direct rule access
  mlxsw: spectrum: Add periodic ACL rule activity update
  mlxsw: spectrum: Add support for Policing and Counting action block
  mlxsw: spectrum: Add support for counters on TCAM entries
  mlxsw: spectrum: Add support for TC flower offload statistics

 drivers/net/ethernet/mellanox/mlxsw/Makefile       |   3 +-
 .../mellanox/mlxsw/core_acl_flex_actions.c         |  51 ++++++
 .../mellanox/mlxsw/core_acl_flex_actions.h         |   2 +
 drivers/net/ethernet/mellanox/mlxsw/reg.h          |  65 +++++++
 drivers/net/ethernet/mellanox/mlxsw/resources.h    |   4 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  67 +++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  20 +++
 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c | 143 ++++++++++++++-
 .../ethernet/mellanox/mlxsw/spectrum_acl_tcam.c    |  42 +++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.c | 198 +++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.h |  53 ++++++
 .../net/ethernet/mellanox/mlxsw/spectrum_flower.c  |  49 +++++
 12 files changed, 695 insertions(+), 2 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.c
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.h

-- 
2.7.4
