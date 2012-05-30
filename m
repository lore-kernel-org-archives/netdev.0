From: Yevgeny Petrilin <yevgenyp@mellanox.com>
Subject: [PATCH net 0/6] batch of mlx4 fixes, mostly to SRIOV
Date: Wed, 30 May 2012 22:14:49 +0300
Message-ID: <1338405295-15427-1-git-send-email-yevgenyp@mellanox.com>
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:56163 "HELO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751238Ab2E3TPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 15:15:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Hi Dave,

Batch of fixes to the mlx4_core and mlx4_en drivers, prepared 
by Jack Morgenstein, who leads our SRIOV development efforts and 
fix various issues all except for one, relate to the driver 
SRIOV functionality.

Jack Morgenstein (5):
  net/mlx4_core: Fix the slave_id out-of-range test in mlx4_eq_int
  net/mlx4_en: Fix improper use of "port" parameter in mlx4_en_event
  net/mlx4_core: Fixes for VF / Guest startup flow
  net/mlx4_core: Check port out-of-range before using in mlx4_slave_cap
  net/mlx4_core: Fix obscure mlx4_cmd_box parameter in QUERY_DEV_CAP

Marcel Apfelbaum (1):
  net/mlx4_core: Fix number of EQs used in ICM initialisation

 drivers/net/ethernet/mellanox/mlx4/cmd.c     |    4 +-
 drivers/net/ethernet/mellanox/mlx4/en_main.c |   12 ++++---
 drivers/net/ethernet/mellanox/mlx4/eq.c      |    2 +-
 drivers/net/ethernet/mellanox/mlx4/fw.c      |   51 ++++++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlx4/main.c    |   40 +++++++--------------
 drivers/net/ethernet/mellanox/mlx4/mlx4.h    |   10 +++++
 drivers/net/ethernet/mellanox/mlx4/profile.c |    9 +++--
 include/linux/mlx4/device.h                  |    6 +++
 8 files changed, 93 insertions(+), 41 deletions(-)

Cc: Jack Morgenstein <jackm@dev.mellanox.co.il>
