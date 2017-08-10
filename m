From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 00/10] netvsc: minor fixes and improvements
Date: Wed,  9 Aug 2017 17:46:02 -0700
Message-ID: <20170810004612.22163-1-sthemmin@microsoft.com>
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:33376 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752220AbdHJAqP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 20:46:15 -0400
Received: by mail-pg0-f46.google.com with SMTP id u5so34542456pgn.0
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 17:46:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These are non-critical bug fixes, related to functionality now in net-next.
 1. delaying the automatic bring up of VF device to allow udev to change name.
 2. performance improvement
 3. handle MAC address change with VF; mostly propogate the error that VF gives.
 4. minor cleanups
 5. allow setting send/receive buffer size with ethtool.

Stephen Hemminger (10):
  netvsc: delay setup of VF device
  netvsc: don't signal host twice if empty
  netvsc: propagate MAC address change to VF slave
  netvsc: check error return when restoring channels and mtu
  netvsc: no need to allocate send/receive on numa node
  netvsc: whitespace cleanup
  netvsc: remove unnecessary cast of void pointer
  netvsc: remove unnecessary check for NULL hdr
  netvsc: allow controlling send/recv buffer size
  netvsc: keep track of some non-fatal overload conditions

 drivers/net/hyperv/hyperv_net.h |  13 ++-
 drivers/net/hyperv/netvsc.c     | 106 ++++++++++-----------
 drivers/net/hyperv/netvsc_drv.c | 203 ++++++++++++++++++++++++++++++++--------
 3 files changed, 227 insertions(+), 95 deletions(-)

-- 
2.11.0
