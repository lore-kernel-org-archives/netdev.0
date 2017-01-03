From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH net-next 0/3] Preparation for VLAN_TAG_PRESENT cleanup
Date: Wed,  4 Jan 2017 00:53:50 +0100 (CET)
Message-ID: <cover.1483487429.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:37054 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966832AbdACXxx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 18:53:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This introduces additional and fixes existing helpers for accessing
skb->vlan_tag.

Michał Mirosław (3):
  net/vlan: introduce __vlan_hwaccel_clear_tag() helper
  net/vlan: introduce __vlan_hwaccel_copy_tag() helper
  net/vlan: include the shift in skb_vlan_tag_get_prio()

 include/linux/if_vlan.h   | 28 ++++++++++++++++++++++++++--
 net/core/flow_dissector.c |  3 +--
 2 files changed, 27 insertions(+), 4 deletions(-)

-- 
2.11.0
