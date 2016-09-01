From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 0/6] mlxsw: couple of fixes
Date: Thu,  1 Sep 2016 10:37:39 +0200
Message-ID: <1472719065-3247-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:38570 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751636AbcIAIhy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 04:37:54 -0400
Received: by mail-wm0-f51.google.com with SMTP id 1so81512590wmz.1
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 01:37:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Couple of fixes from Ido and myself.

Ido Schimmel (2):
  mlxsw: spectrum: Don't take multiple references on a FID
  mlxsw: spectrum: Use existing flood setup when adding VLANs

Jiri Pirko (4):
  mlxsw: spectrum_router: Fix failure caused by double fib removal from
    HW
  mlxsw: spectrum_router: Fix fib entry update path
  mlxsw: spectrum: Fix error path in mlxsw_sp_module_init
  mlxsw: spectrum_router: Fix netevent notifier registration

 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  10 ++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   2 +
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 151 +++++++++++++--------
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   |  28 ++--
 4 files changed, 120 insertions(+), 71 deletions(-)

-- 
2.5.5
