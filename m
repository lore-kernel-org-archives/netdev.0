From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/5] mlxsw: ethtool enhancements
Date: Mon, 12 Sep 2016 13:26:22 +0200
Message-ID: <1473679587-9112-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:36420 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753421AbcILL0a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 07:26:30 -0400
Received: by mail-wm0-f44.google.com with SMTP id b187so130529499wme.1
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 04:26:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Ido says:

Patches 1-4 do some minor cleanup in current ethtool ops. Patch 5
replace legacy {get,set}_settings callbacks with
{get,set}_link_ksettings.

Ido Schimmel (5):
  mlxsw: spectrum: Correctly report autonegotiation
  mlxsw: spectrum: Report link partner's advertised speeds
  mlxsw: spectrum: Report port type according to operational speed
  mlxsw: spectrum: Indicate support of multiple port types
  mlxsw: spectrum: Add support for new ethtool API

 drivers/net/ethernet/mellanox/mlxsw/reg.h      |  20 ++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 332 ++++++++++++++-----------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h |   3 +-
 3 files changed, 209 insertions(+), 146 deletions(-)

-- 
2.5.5
