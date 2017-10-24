From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/3] mlxsw: Various fixes
Date: Tue, 24 Oct 2017 11:17:14 +0200
Message-ID: <20171024091717.1180-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:52952 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751323AbdJXJRT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 05:17:19 -0400
Received: by mail-wm0-f67.google.com with SMTP id 78so11949251wmb.1
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2017 02:17:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Yotam says:

Cleanup some issues reported by sparse.

Yotam Gigi (3):
  mlxsw: spectrum: mr: Fix various endianness issues
  mlxsw: spectrum: mr: Make the function mlxsw_sp_mr_dev_vif_lookup
    static
  mlxsw: spectrum: mr_tcam: Include the mr_tcam header file

 drivers/net/ethernet/mellanox/mlxsw/spectrum_mr.c      | 13 +++++++------
 drivers/net/ethernet/mellanox/mlxsw/spectrum_mr_tcam.c |  1 +
 2 files changed, 8 insertions(+), 6 deletions(-)

-- 
2.9.5
