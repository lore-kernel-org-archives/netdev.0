From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 0/5] mlxsw: Couple of fixes
Date: Fri, 15 Jul 2016 11:14:57 +0200
Message-ID: <1468574102-26288-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:38604 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932286AbcGOJPG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 05:15:06 -0400
Received: by mail-wm0-f52.google.com with SMTP id o80so20046602wme.1
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 02:15:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Couple of fixes for mlxsw driver from Ido.

Ido Schimmel (5):
  mlxsw: spectrum: Force link training according to admin state
  mlxsw: spectrum: Indicate support for autonegotiation
  mlxsw: spectrum: Don't emit errors when PFC is disabled
  mlxsw: spectrum: Prevent overwrite of DCB capability fields
  mlxsw: spectrum: Prevent invalid ingress buffer mapping

 drivers/net/ethernet/mellanox/mlxsw/reg.h          | 17 ++++++++++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 28 +++-------------------
 .../net/ethernet/mellanox/mlxsw/spectrum_buffers.c |  2 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c |  8 +++++--
 4 files changed, 26 insertions(+), 29 deletions(-)

-- 
2.5.5
