From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH iproute2 net-next 0/5] add latest bridge netlink options
Date: Tue, 17 Jan 2017 17:32:27 +0800
Message-ID: <1484645552-29440-1-git-send-email-liuhangbin@gmail.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34533 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751438AbdAQJcu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 04:32:50 -0500
Received: by mail-pg0-f66.google.com with SMTP id t6so3497268pgt.1
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 01:32:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the bridge netlink attributes added to kernel recently.

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
