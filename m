From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 00/18] netvsc driver enhancements for net-next
Date: Tue, 24 Jan 2017 13:05:57 -0800
Message-ID: <20170124210615.18628-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net, kys@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:36230 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750763AbdAXVG7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 16:06:59 -0500
Received: by mail-pf0-f174.google.com with SMTP id 189so52616505pfu.3
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 13:06:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lots of little things in here. Support for minor more ethtool control,
negotiation of offload parameters with host (based on FreeBSD) and
several cleanups.

Stephen Hemminger (18):
  netvsc: remove no longer needed receive staging buffers
  netvsc: negotiate checksum and segmentation parameters
  netvsc: report number of rx queues in ethtool
  netvsc: report rss field values
  netvsc: add ethtool ops to get/set RSS key
  netvsc: allow more flexible setting of number of channels
  netvsc: allow get/set of RSS indirection table
  netvsc: enhance transmit select_queue
  netvsc: remove unused variables
  netvsc: group all per-channel state together
  netvsc: optimize receive path
  netvsc: don't pass void * to internal device_add
  netvsc: simplify rndis_filter_remove
  netvsc: eliminate per-device outstanding send counter
  netvsc: account for packets/bytes transmitted after completion
  netvsc: report per-channel stats in ethtool statistics
  netvsc: simplify get next send section
  netvsc: call netif_receive_skb

 drivers/net/hyperv/hyperv_net.h   | 216 ++++++++++++---
 drivers/net/hyperv/netvsc.c       | 321 ++++++++-------------
 drivers/net/hyperv/netvsc_drv.c   | 569 +++++++++++++++++++++++---------------
 drivers/net/hyperv/rndis_filter.c | 338 ++++++++++++++--------
 4 files changed, 850 insertions(+), 594 deletions(-)

-- 
2.11.0
