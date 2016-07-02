From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 00/12] mlxsw: Lay the groundwork for the introduction of router interfaces
Date: Sat,  2 Jul 2016 11:00:08 +0200
Message-ID: <1467450020-23415-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34895 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751029AbcGBJAX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2016 05:00:23 -0400
Received: by mail-wm0-f65.google.com with SMTP id a66so10281360wme.2
        for <netdev@vger.kernel.org>; Sat, 02 Jul 2016 02:00:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This is first patchset on a way to introduce ipv4 routing offload support
in mlxsw driver. Does preparations before router interfaces will
be introduced in mlxsw.

Ido Schimmel (11):
  mlxsw: spectrum: Send untagged packets through a port netdev
  mlxsw: spectrum: Remove VLANs configuration via SELF flag
  mlxsw: spectrum: Sync PVID vPort LAG status
  mlxsw: spectrum: Remove RIF from PVID vPort when joining / leaving LAG
  mlxsw: reg: Add Router General Configuration Register
  mlxsw: spectrum: Initialize ports at the end of init sequence
  mlxsw: spectrum_router: Add basic ipv4 router initialization
  mlxsw: spectrum: Add router interface struct
  mlxsw: reg: Add FDB action to forward to router
  mlxsw: reg: Add Router Interface Table Register
  mlxsw: spectrum: Use action 'discard' when removing traps

Jiri Pirko (1):
  mlxsw: spectrum: Add traps needed for router implementation

 drivers/net/ethernet/mellanox/mlxsw/Makefile       |   2 +-
 drivers/net/ethernet/mellanox/mlxsw/reg.h          | 276 ++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 137 +++++++---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  26 +-
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  |  68 +++++
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   |  46 +---
 drivers/net/ethernet/mellanox/mlxsw/trap.h         |   5 +
 7 files changed, 474 insertions(+), 86 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c

-- 
2.5.5
