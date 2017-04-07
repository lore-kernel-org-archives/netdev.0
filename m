From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 0/8] rtnetlink: Cleanup user notifications for netdev events
Date: Fri,  7 Apr 2017 14:25:32 -0700
Message-ID: <1491600340-8359-1-git-send-email-dsa@cumulusnetworks.com>
Cc: vyasevic@redhat.com, davem@davemloft.net,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:36777 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933390AbdDGVZq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 17:25:46 -0400
Received: by mail-pg0-f47.google.com with SMTP id g2so76020695pge.3
        for <netdev@vger.kernel.org>; Fri, 07 Apr 2017 14:25:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vlad's recent patch to add the event type to rtnetlink notifications
points out a number of redundant or unnecessary notifications sent to
userspace for events that are essentially internal to the kernel. Trim
the list before the new IFLA attributes become part of the UAPI.

David Ahern (8):
  rtnetlink: Do not generate notifications for MTU events
  rtnetlink: Do not generate notification for UDP_TUNNEL_PUSH_INFO
  rtnetlink: Do not generate notifications for CHANGEADDR event
  rtnetlink: Do not generate notifications for POST_TYPE_CHANGE event
  rtnetlink: Remove NETDEV_CHANGEINFODATA netdev event
  rtnetlink: Do not generate notifications for PRECHANGEUPPER event
  rtnetlink: Do not generate notifications for NOTIFY_PEERS event
  rtnetlink: Do not generate notifications for CHANGELOWERSTATE event

 drivers/net/bonding/bond_options.c |  2 --
 include/linux/netdevice.h          |  1 -
 include/uapi/linux/if_link.h       |  9 ---------
 net/core/rtnetlink.c               | 36 ------------------------------------
 4 files changed, 48 deletions(-)

-- 
2.1.4
