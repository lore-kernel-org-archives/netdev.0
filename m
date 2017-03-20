From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 0/2] netvsc: performance regressions in net-next
Date: Mon, 20 Mar 2017 13:28:03 -0700
Message-ID: <20170320202805.19362-1-sthemmin@microsoft.com>
Cc: haiyangz@microsoft.com, netdev@vger.kernel.org,
        Stephen Hemminger <sthemmin@microsoft.com>
To: kys@microsoft.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:33267 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932249AbdCTU2X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 16:28:23 -0400
Received: by mail-pg0-f41.google.com with SMTP id n190so82788647pga.0
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 13:28:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix for performance regression introduced with NAPI change;
and followup cleanup of vmbus core code.

Stephen Hemminger (2):
  netvsc: fix NAPI performance regression
  vmbus: no longer expose iterator internals

 drivers/hv/ring_buffer.c        | 51 +++++++++++++++++++++--------------------
 drivers/net/hyperv/hyperv_net.h |  1 +
 drivers/net/hyperv/netvsc.c     | 41 +++++++++++++++------------------
 include/linux/hyperv.h          | 22 +-----------------
 4 files changed, 46 insertions(+), 69 deletions(-)

-- 
2.11.0
