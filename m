From: Pravin B Shelar <pshelar@ovn.org>
Subject: [PATCH net-next v2 0/7] vxlan: General improvements.
Date: Sat,  5 Nov 2016 11:45:50 -0700
Message-ID: <1478371557-71888-1-git-send-email-pshelar@ovn.org>
Cc: Pravin B Shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:53832 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754524AbcKESqD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Nov 2016 14:46:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch series improves vxlan fast path, removes
duplicate code and simplifies vxlan xmit code path.

v1-v2:
Fix compilation error when IPv6 support is not enabled.

Pravin B Shelar (7):
  vxlan: avoid vlan processing in vxlan device.
  vxlan: simplify exception handling
  vxlan: avoid checking socket multiple times.
  vxlan: improve vxlan route lookup checks.
  vxlan: simplify RTF_LOCAL handling.
  vxlan: simplify vxlan xmit
  vxlan: remove unsed vxlan_dev_dst_port()

 drivers/net/vxlan.c     | 275 +++++++++++++++++++++++-------------------------
 include/linux/if_vlan.h |  16 ---
 include/net/vxlan.h     |  10 --
 3 files changed, 133 insertions(+), 168 deletions(-)

-- 
1.9.1
