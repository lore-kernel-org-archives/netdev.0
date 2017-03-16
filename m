From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 0/3] netvsc: small changesfor net-next
Date: Thu, 16 Mar 2017 16:12:36 -0700
Message-ID: <20170316231239.12996-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: kys@microsoft.com, davem@davemloft.net, haiyangz@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:32943 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752191AbdCPXMt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 19:12:49 -0400
Received: by mail-pg0-f44.google.com with SMTP id n190so32055035pga.0
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 16:12:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One bugfix, and two non-code patches

Stephen Hemminger (3):
  netvsc: avoid race with callback
  netvsc: add comments about callback's and NAPI
  netvsc: remove unused #define

 drivers/net/hyperv/hyperv_net.h   |  3 ---
 drivers/net/hyperv/netvsc.c       | 31 +++++++++++++++++--------------
 drivers/net/hyperv/rndis_filter.c | 15 ++++++++++-----
 3 files changed, 27 insertions(+), 22 deletions(-)

-- 
2.11.0
