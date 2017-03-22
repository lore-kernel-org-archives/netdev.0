From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 0/9] netvsc: bug fixes and cleanups
Date: Wed, 22 Mar 2017 14:50:56 -0700
Message-ID: <20170322215105.1059-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, haiyangz@microsoft.com,
        Stephen Hemminger <sthemmin@microsoft.com>
To: kys@microsoft.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33533 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751153AbdCVVvO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 17:51:14 -0400
Received: by mail-pf0-f176.google.com with SMTP id o190so15167152pfo.0
        for <netdev@vger.kernel.org>; Wed, 22 Mar 2017 14:51:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These fix NAPI issues and bugs found during testing of shutdown
testing.

Stephen Hemminger (9):
  netvsc: fix NAPI performance regression
  netvsc: handle offline mtu and channel change
  netvsc: change max channel calculation
  netvsc: use RCU to protect inner device structure
  netvsc: uses RCU instead of removal flag
  netvsc: use refcount_t for keeping track of sub channels
  netvsc: remove unnecessary lock on shutdown
  netvsc: eliminate unnecessary skb == NULL checks
  netvsc: fix and cleanup rndis_filter_set_packet_filter

 drivers/net/hyperv/hyperv_net.h   |  12 ++--
 drivers/net/hyperv/netvsc.c       |  70 ++++++++++------------
 drivers/net/hyperv/netvsc_drv.c   | 121 ++++++++++++++++++++++----------------
 drivers/net/hyperv/rndis_filter.c |  91 +++++++++-------------------
 4 files changed, 138 insertions(+), 156 deletions(-)

-- 
2.11.0
