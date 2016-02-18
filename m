From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 0/2] mlxsw fixes
Date: Thu, 18 Feb 2016 11:30:00 +0100
Message-ID: <1455791402-12976-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:35839 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1426261AbcBRKaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 05:30:06 -0500
Received: by mail-wm0-f50.google.com with SMTP id c200so19534205wme.0
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 02:30:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Another bulk of fixes from Ido.

Ido Schimmel (2):
  mlxsw: reg: Add the Switch Port Acceptable Frame Types register
  mlxsw: spectrum: Allow for PVID deletion

 drivers/net/ethernet/mellanox/mlxsw/reg.h          | 58 ++++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  2 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  1 +
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 69 +++++++++++++++++++---
 4 files changed, 121 insertions(+), 9 deletions(-)

-- 
2.5.0
