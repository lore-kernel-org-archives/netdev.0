From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 0/2] net/mlx4: Add dynamic policy changes to the SRIOV eSwitch support
Date: Thu, 27 Jun 2013 19:05:20 +0300
Message-ID: <1372349122-23390-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, jackm@dev.mellanox.co.il,
	ronye@mellanox.com, Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:46636 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752241Ab3F0QF7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jun 2013 12:05:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch set from Jack and Rony uses the UPDATE_QP new firmware command 
to allow for dynamic policy changes of PF controlled VF vlan/qos and link-state.

Done against net-next commit 8599b52e14 "bonding: add an option to fail when any 
of arp_ip_target is inaccessible"

Or.


Jack Morgenstein (1):
  net/mlx4_core: Dynamic VST to VST vlan/qos changes

Rony Efraim (1):
  net/mlx4_core: Add HW enforcement to VF link state

 drivers/net/ethernet/mellanox/mlx4/cmd.c           |  149 +++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx4/fw.c            |    5 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |   21 +++
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |  163 +++++++++++++++++++-
 include/linux/mlx4/cmd.h                           |    1 +
 include/linux/mlx4/device.h                        |    3 +-
 include/linux/mlx4/qp.h                            |   36 +++++
 7 files changed, 362 insertions(+), 16 deletions(-)
