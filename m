From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH 0/4] drivers/net: fix too big NAPI weights
Date: Wed, 21 Aug 2013 18:49:27 +0200
Message-ID: <1377103771-1590-1-git-send-email-mschmidt@redhat.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45060 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751621Ab3HUQtg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Aug 2013 12:49:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some drivers request too big NAPI weights and would trigger the error
message in netif_napi_add() added in commit 82dc3c63. Let's fix them.

Michal Schmidt (4):
  jme: lower NAPI weight
  netxen: lower NAPI weight
  ps3_gelic: lower NAPI weight
  qlcnic: use standard NAPI weights

 drivers/net/ethernet/jme.c                         |  2 +-
 drivers/net/ethernet/qlogic/netxen/netxen_nic.h    |  1 -
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |  2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |  1 -
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     | 25 +++++++++-------------
 drivers/net/ethernet/toshiba/ps3_gelic_net.c       |  3 +--
 drivers/net/ethernet/toshiba/ps3_gelic_net.h       |  1 -
 7 files changed, 13 insertions(+), 22 deletions(-)

-- 
1.8.3.1
