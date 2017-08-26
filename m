From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/2] mlxsw: spectrum: Fix couple of dpipe ipv4 host table bugs
Date: Sat, 26 Aug 2017 08:35:37 +0200
Message-ID: <20170826063539.2741-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:38368 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750737AbdHZGfn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Aug 2017 02:35:43 -0400
Received: by mail-wr0-f194.google.com with SMTP id o76so965684wrb.5
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 23:35:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Arkadi Sharshevsky (1):
  mlxsw: spectrum_dpipe: Fix host table dump

Jiri Pirko (1):
  mlxsw: spectrum: compile-in dpipe support only if devlink is enabled

 drivers/net/ethernet/mellanox/mlxsw/Makefile         |  3 ++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c |  3 +++
 drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.h | 15 +++++++++++++++
 3 files changed, 20 insertions(+), 1 deletion(-)

-- 
2.9.3
