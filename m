From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 0/4] mlxsw: Couple of fixes
Date: Thu, 20 Oct 2016 16:05:41 +0200
Message-ID: <1476972345-31568-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:33918 "EHLO
        mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753299AbcJTOFs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 10:05:48 -0400
Received: by mail-qk0-f176.google.com with SMTP id f128so92267447qkb.1
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 07:05:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Elad Raz (1):
  mlxsw: switchx2: Fix ethernet port initialization

Jiri Pirko (3):
  mlxsw: spectrum_router: Use correct tree index for binding
  mlxsw: spectrum_router: Make mlxsw_sp_router_fib4_del return void and
    remove warn
  mlxsw: pci: Fix reset wait for SwitchX2

 drivers/net/ethernet/mellanox/mlxsw/pci.c             | 10 ++++++++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 16 +++++++---------
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c        |  1 +
 3 files changed, 16 insertions(+), 11 deletions(-)

-- 
2.5.5
