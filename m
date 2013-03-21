From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 0/5] Mellanox Core and Ethernet driver fixes 2013-03-21
Date: Thu, 21 Mar 2013 17:55:50 +0200
Message-ID: <1363881355-21137-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	jackm@dev.mellanox.co.il, hadarh@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:53833 "EHLO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755978Ab3CUP4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 11:56:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Here's a batch of mlx4 driver fixes for 3.9, mostly SRIOV/Flow-steering
related. Series done against the net tree as of commit 5a3da1f
"inet: limit length of fragment queue hash table bucket lists

Or.

Hadar Hen Zion (4):
  net/mlx4_core: Fix wrong order of flow steering resources removal
  net/mlx4_en: Remove ethtool flow steering rules before releasing QPs
  net/mlx4_core: Always use 64 bit resource ID when doing lookup
  net/mlx4_core: Disallow releasing VF QPs which have steering rules

Moshe Lazer (1):
  net/mlx4_core: Fix wrong mask applied on EQ numbers in the wrapper

 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |   22 +++++-----
 drivers/net/ethernet/mellanox/mlx4/eq.c            |    2 +-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   45 +++++++++++++++----
 3 files changed, 47 insertions(+), 22 deletions(-)
