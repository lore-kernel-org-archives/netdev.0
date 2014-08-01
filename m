From: Andy Zhou <azhou@nicira.com>
Subject: [net-next 0/5] Add common UDP tunnel functions
Date: Fri,  1 Aug 2014 14:54:40 -0700
Message-ID: <1406930085-26445-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog134.obsmtp.com ([74.125.149.83]:42951 "HELO
	na3sys009aog134.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755715AbaHAV7i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 17:59:38 -0400
Received: by mail-pd0-f178.google.com with SMTP id w10so6302884pde.9
        for <netdev@vger.kernel.org>; Fri, 01 Aug 2014 14:59:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series add a few more UDP tunnel common functions.
Also refactor vxlan and l2tp drivers to make use of the newly
added APIs.

Andy Zhou (5):
  net: Add rx-vxlan feature bit
  udp: Expand UDP tunnel common APIs
  net: Refactor vxlan driver to make use of common UDP tunnel functions
  l2tp: Small cleanups
  l2tp: refactor l2tp driver to use udp tunnel functions

 Documentation/networking/netdev-features.txt     |    5 +
 drivers/net/ethernet/emulex/benet/be_main.c      |   22 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c      |   19 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c   |   29 ++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |   25 +-
 drivers/net/vxlan.c                              |  275 ++++++----------------
 include/linux/netdev_features.h                  |    4 +
 include/linux/netdevice.h                        |   43 ++--
 include/net/udp_tunnel.h                         |   53 +++++
 include/net/vxlan.h                              |   23 +-
 net/core/ethtool.c                               |    1 +
 net/ipv4/udp_tunnel.c                            |  271 ++++++++++++++++++++-
 net/l2tp/l2tp_core.c                             |  176 ++++++++------
 net/openvswitch/vport-vxlan.c                    |    6 +-
 14 files changed, 605 insertions(+), 347 deletions(-)

-- 
1.7.9.5
