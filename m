From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/5] mlxsw: small driver update
Date: Mon,  9 Jan 2017 11:25:43 +0100
Message-ID: <1483957548-3531-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f195.google.com ([209.85.210.195]:35602 "EHLO
        mail-wj0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750710AbdAIKZv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 05:25:51 -0500
Received: by mail-wj0-f195.google.com with SMTP id ey1so5133479wjd.2
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 02:25:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This patchset contains various small "non-net" fixes and enhancements.

Elad Raz (2):
  mlxsw: Fix mlxsw_i2c_write return value
  mlxsw: cmd: Fix API name comments for event-queues

Yotam Gigi (3):
  mlxsw: spectrum: Make the add_matchall_tc_entry symmetric
  mlxsw: spectrum: Fix order of commands in port remove function
  mlxsw: spectrum: Change ENOTSUPP to EOPNOTSUPP

 drivers/net/ethernet/mellanox/mlxsw/cmd.h      |  10 +--
 drivers/net/ethernet/mellanox/mlxsw/i2c.c      |   2 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 101 +++++++++++++------------
 3 files changed, 59 insertions(+), 54 deletions(-)

-- 
2.7.4
