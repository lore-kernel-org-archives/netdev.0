From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/4] mlxsw: couple of fixes
Date: Mon,  4 Jan 2016 10:42:22 +0100
Message-ID: <1451900546-2006-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:38235 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751505AbcADJm3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 04:42:29 -0500
Received: by mail-wm0-f48.google.com with SMTP id b14so175822858wmb.1
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 01:42:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Couple of fixes from Ido.

Ido Schimmel (4):
  mlxsw: spectrum: Initialize PVID only once
  mlxsw: spectrum: Return NOTIFY_BAD on bridge failure
  mlxsw: spectrum: Set bridge status in appropriate functions
  mlxsw: spectrum: Change bridge port attributes only when bridged

 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 37 ++++++++++++----------
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   |  3 ++
 2 files changed, 23 insertions(+), 17 deletions(-)

-- 
1.9.3
