From: sthemmin@exchange.microsoft.com
Subject: [PATCH net-next 00/14] hv_netvsc: cleanups
Date: Tue, 23 Aug 2016 12:29:32 -0700
Message-ID: <1471980586-18263-1-git-send-email-sthemmin@exchange.microsoft.com>
Reply-To: sthemmin@microsoft.com
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtps2ded02.prod.phx3.secureserver.net ([208.109.80.59]:41160
        "EHLO p3plsmtps2ded02.prod.phx3.secureserver.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754274AbcHWRy3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 Aug 2016 13:54:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <sthemmin@microsoft.com>

Hyper-V network driver cleanups.

The only new functionality is minor extensions to ethtool.

Apologies if this was already sent, still working out the
new email send methodolgy.

Stephen Hemminger (14):
  hv_netvsc: fix rtnl locking in callback
  hv_netvsc: make RSS hash key static
  hv_netvsc: use kcalloc
  hv_netvsc: style cleanups
  hv_netvsc: make inline functions static
  hv_netvsc: use ARRAY_SIZE() for NDIS versions
  hv_netvsc: make device_remove void
  hv_netvsc: init completion during alloc
  hv_netvsc: rearrange start_xmit
  hv_netvsc: refactor completion function
  hv_netvsc: make netvsc_destroy_buf void
  hv_netvsc: make variable local
  hv_netvsc: report vmbus name in ethtool
  hv_netvsc: add ethtool statistics for tx packet issues

 drivers/net/hyperv/hyperv_net.h   |   13 ++-
 drivers/net/hyperv/netvsc.c       |  242 ++++++++++++++++++++++++-------------
 drivers/net/hyperv/netvsc_drv.c   |  194 ++++++++++++++++++------------
 drivers/net/hyperv/rndis_filter.c |   11 +--
 include/linux/hyperv.h            |   91 +-------------
 5 files changed, 297 insertions(+), 254 deletions(-)

-- 
1.7.4.1
