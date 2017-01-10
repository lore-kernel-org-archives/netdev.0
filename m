From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 00/10] Mellanox mlx5 fixes and cleanups 2017-01-10
Date: Tue, 10 Jan 2017 22:33:29 +0200
Message-ID: <1484080419-24256-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:52047 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751074AbdAJUe1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 15:34:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series includes some mlx5e general cleanups from Daniel, Gil, Hadar
and myself.
Also it includes some critical mlx5e TC offloads fixes from Or Gerlitz.

For -stable:
 - net/mlx5e: Remove WARN_ONCE from adaptive moderation code

   Although this fix doesn't affect any functionality, I thought it is
   better to clean this -WARN_ONCE- up for -stable in case someone hits
   such corner case.

Please apply and let me know if there's any problem.

Thanks,
Saeed.

Daniel Jurgens (1):
  net/mlx5: Only cancel recovery work when cleaning up device

Gil Rockah (1):
  net/mlx5e: Remove WARN_ONCE from adaptive moderation code

Hadar Hen Zion (1):
  net/mlx5e: Fix kbuild warnings for uninitialized parameters

Or Gerlitz (6):
  net/mlx5e: Properly handle offloading of source udp port for IP
    tunnels
  net/mlx5e: Warn when rejecting offload attempts of IP tunnels
  net/mlx5e: TC ipv4 tunnel encap offload error flow fixes
  net/mlx5e: Properly get address type of encapsulation IP headers
  net/mlx5e: Set inline mode requirements for matching on IP fragments
  net/mlx5e: Properly handle FW errors while adding TC rules

Saeed Mahameed (1):
  net/mlx5e: Un-register uplink representor on nic_disable

 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 13 ++-
 drivers/net/ethernet/mellanox/mlx5/core/en_rx_am.c |  7 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    | 93 +++++++++++++++-------
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |  6 +-
 4 files changed, 75 insertions(+), 44 deletions(-)

-- 
2.7.4
