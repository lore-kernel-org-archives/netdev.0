From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net 0/5] NAPI support for Hyper-V
Date: Mon, 27 Feb 2017 10:26:46 -0800
Message-ID: <20170227182651.3956-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:36480 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751552AbdB0SgD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 13:36:03 -0500
Received: by mail-pf0-f181.google.com with SMTP id 89so5838992pfi.3
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 10:34:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches enable NAPI, GRO and napi_alloc_skb for Hyper-V netvsc
driver.

Stephen Hemminger (5):
  netvsc: don't overload variable in same function
  vmbus: introduce in-place packet iterator
  netvsc: implement NAPI
  netvsc: enable GRO
  netvsc: replace netdev_alloc_skb_ip_align with napi_alloc_skb

 drivers/hv/ring_buffer.c          |  94 ++++++++++++++++++++-
 drivers/net/hyperv/hyperv_net.h   |   2 +
 drivers/net/hyperv/netvsc.c       | 172 ++++++++++++++++++++++++--------------
 drivers/net/hyperv/netvsc_drv.c   |  19 ++---
 drivers/net/hyperv/rndis_filter.c |   2 +
 include/linux/hyperv.h            |  96 +++++++--------------
 6 files changed, 242 insertions(+), 143 deletions(-)

-- 
2.11.0
