From: Pravin B Shelar <pshelar@ovn.org>
Subject: [PATCH net-next 0/7] vxlan: General improvements.
Date: Fri,  4 Nov 2016 13:51:49 -0700
Message-ID: <1478292716-54649-1-git-send-email-pshelar@ovn.org>
Cc: Pravin B Shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:48786 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758605AbcKDUwC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 16:52:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch series improves vxlan fast path, removes
duplicate code and simplifies vxlan xmit code path.

Pravin B Shelar (7):
  vxlan: avoid vlan processing in vxlan device.
  vxlan: simplify exception handling
  vxlan: avoid checking socket multiple times.
  vxlan: improve vxlan route lookup checks.
  vxlan: simplify RTF_LOCAL handling.
  vxlan: simplify vxlan xmit
  vxlan: remove unsed vxlan_dev_dst_port()

 drivers/net/vxlan.c     | 264 ++++++++++++++++++++++--------------------------
 include/linux/if_vlan.h |  16 ---
 include/net/vxlan.h     |  10 --
 3 files changed, 123 insertions(+), 167 deletions(-)

-- 
1.9.1
