From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 0/5 net] bridge: Fix missing Netlink message validations
Date: Wed, 26 Nov 2014 13:42:15 +0100
Message-ID: <cover.1417005245.git.tgraf@suug.ch>
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:56805 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750783AbaKZMm1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 07:42:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds various missing length checks in the bridging code for Netlink
messages and corresponding attributes provided by user space.

Thomas Graf (5):
  bridge: Validate IFLA_BRIDGE_FLAGS attribute length
  net: Validate IFLA_BRIDGE_MODE attribute length
  net: Check for presence of IFLA_AF_SPEC
  bridge: Add missing policy entry for IFLA_BRPORT_FAST_LEAVE
  bridge: Sanitize IFLA_EXT_MASK for AF_BRIDGE:RTM_GETLINK

 drivers/net/ethernet/emulex/benet/be_main.c   |  5 +++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  5 +++++
 net/bridge/br_netlink.c                       |  1 +
 net/core/rtnetlink.c                          | 23 ++++++++++++++++++-----
 4 files changed, 29 insertions(+), 5 deletions(-)

-- 
1.9.3
