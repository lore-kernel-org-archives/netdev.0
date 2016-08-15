From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 0/9] mlxsw: couple of fixes
Date: Mon, 15 Aug 2016 16:37:44 +0200
Message-ID: <1471271873-4389-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:38015 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753148AbcHOOh4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 10:37:56 -0400
Received: by mail-wm0-f51.google.com with SMTP id o80so107394134wme.1
        for <netdev@vger.kernel.org>; Mon, 15 Aug 2016 07:37:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Elad Raz (1):
  mlxsw: spectrum: Add missing packet traps

Ido Schimmel (7):
  mlxsw: spectrum: Don't return upon error in removal path
  mlxsw: spectrum: Remove redundant errors from the code
  mlxsw: spectrum: Create PVID vPort before registering netdevice
  mlxsw: spectrum: Mark port as active before registering it
  mlxsw: spectrum: Add missing rollbacks in error path
  mlxsw: spectrum: Unmap 802.1Q FID before destroying it
  mlxsw: spectrum: Allow packets to be trapped from any PG

Jiri Pirko (1):
  mlxsw: reg: Fix missing op field fill-up

 drivers/net/ethernet/mellanox/mlxsw/reg.h          |   1 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 105 +++++++++++----------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   2 -
 .../net/ethernet/mellanox/mlxsw/spectrum_buffers.c |   2 +-
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   |  42 ++-------
 drivers/net/ethernet/mellanox/mlxsw/trap.h         |   3 +
 6 files changed, 67 insertions(+), 88 deletions(-)

-- 
2.5.5
