From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 00/11] mlxsw: driver fixes
Date: Wed, 27 Jan 2016 15:20:15 +0100
Message-ID: <1453904426-4960-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:34306 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753617AbcA0OUa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2016 09:20:30 -0500
Received: by mail-wm0-f52.google.com with SMTP id n5so30544193wmn.1
        for <netdev@vger.kernel.org>; Wed, 27 Jan 2016 06:20:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Couple of various mlxsw driver fixes.

Ido Schimmel (11):
  mlxsw: spectrum: Handle port leaving LAG while bridged
  mlxsw: reg: Add the Switch Filtering DB Flush register
  mlxsw: spectrum: Flush FDB when leaving bridge
  mlxsw: spectrum: Don't forward packets when STP state is DISABLED
  mlxsw: spectrum: Disable learning according to STP state
  mlxsw: spectrum: Notify bridge's FDB only based on learning_sync
  mlxsw: spectrum: Don't report VLAN for 802.1D FDB entries
  mlxsw: spectrum: Use correct netdev when notifying bridge
  mlxsw: spectrum: Dump LAG FDB records only once
  mlxsw: spectrum: Compare local ports instead of pointers
  mlxsw: reg: Use correct offset in field definiton

 drivers/net/ethernet/mellanox/mlxsw/reg.h          |  94 +++++++++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 161 ++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   1 +
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   |  77 ++++++----
 4 files changed, 293 insertions(+), 40 deletions(-)

-- 
1.9.3
