From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/6] rocker: make master change handling nicer
Date: Wed, 26 Aug 2015 18:36:32 +0200
Message-ID: <1440606998-11072-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, simon.horman@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:34870 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751840AbbHZQgk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 12:36:40 -0400
Received: by wicne3 with SMTP id ne3so50323219wic.0
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 09:36:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Jiri Pirko (6):
  net: introduce change upper device notifier change info
  net: add netif_is_bridge_master helper
  net: add netif_is_ovs_master helper with IFF_OPENVSWITCH private flag
  net: kill long time unused bonding private flags
  rocker: use new helper to figure out master kind
  rocker: use change upper info

 drivers/net/ethernet/rocker/rocker.c | 74 ++++++++++++++++++++---------------
 include/linux/netdevice.h            | 75 +++++++++++++++++++-----------------
 net/core/dev.c                       | 16 +++++++-
 net/openvswitch/vport-internal_dev.c |  2 +-
 4 files changed, 97 insertions(+), 70 deletions(-)

-- 
1.9.3
