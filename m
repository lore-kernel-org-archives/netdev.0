From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCHv2 iproute2 net-next 0/5] add latest bridge netlink options
Date: Wed, 18 Jan 2017 14:12:46 +0800
Message-ID: <1484719971-21693-1-git-send-email-liuhangbin@gmail.com>
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34752 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751024AbdARGVV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 01:21:21 -0500
Received: by mail-pf0-f195.google.com with SMTP id y143so417017pfb.1
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 22:21:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the bridge netlink attributes added to kernel recently.

v2: rename vlan/mcast_state to vlan/mcast_stats_enabled as suggested by
Nikolay. The previous name has different meaning and will mislead people.
I will post a separate patch for IFLA_BRPORT_FLUSH support.

Hangbin Liu (5):
  iplink: bridge: add support for IFLA_BR_FDB_FLUSH
  iplink: bridge: add support for IFLA_BR_VLAN_STATS_ENABLED
  iplink: bridge: add support for IFLA_BR_MCAST_STATS_ENABLED
  iplink: bridge: add support for IFLA_BR_MCAST_IGMP_VERSION
  iplink: bridge: add support for IFLA_BR_MCAST_MLD_VERSION

 ip/iplink_bridge.c | 57 +++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 56 insertions(+), 1 deletion(-)

-- 
2.5.5
