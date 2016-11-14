From: Pravin B Shelar <pshelar@ovn.org>
Subject: [PATCH net-next v3 0/7] vxlan: xmit improvements.
Date: Sun, 13 Nov 2016 20:43:51 -0800
Message-ID: <1479098638-4921-1-git-send-email-pshelar@ovn.org>
Cc: Pravin B Shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:56708 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751201AbcKNEoE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 23:44:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch series improves vxlan fast path, removes
duplicate code and simplifies vxlan xmit code path.

v2-v3:
Removed unrelated warning fix from patch 2.
rearranged error handling from patch 3
Fixed stats updates in vxlan route lookup in patch 4

v1-v2:
Fix compilation error when IPv6 support is not enabled.


Pravin B Shelar (7):
  vxlan: avoid vlan processing in vxlan device.
  vxlan: avoid checking socket multiple times.
  vxlan: simplify exception handling
  vxlan: improve vxlan route lookup checks.
  vxlan: simplify RTF_LOCAL handling.
  vxlan: simplify vxlan xmit
  vxlan: remove unsed vxlan_dev_dst_port()

 drivers/net/vxlan.c     | 285 +++++++++++++++++++++++-------------------------
 include/linux/if_vlan.h |  16 ---
 include/net/vxlan.h     |  10 --
 3 files changed, 137 insertions(+), 174 deletions(-)

-- 
1.9.1
