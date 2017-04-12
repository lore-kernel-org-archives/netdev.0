From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v2 6/8] rtnetlink: Do not generate notifications for CHANGELOWERSTATE event
Date: Tue, 11 Apr 2017 17:02:45 -0700
Message-ID: <1491955367-12443-7-git-send-email-dsa@cumulusnetworks.com>
References: <1491955367-12443-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:35128 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753159AbdDLAC5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 20:02:57 -0400
Received: by mail-pf0-f176.google.com with SMTP id i5so5452692pfc.2
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 17:02:57 -0700 (PDT)
In-Reply-To: <1491955367-12443-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CHANGELOWERSTATE is an internal event; do not generate userspace
notifications.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/core/rtnetlink.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 10df445bb818..b70e915be66d 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -4124,7 +4124,6 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 	case NETDEV_CHANGEUPPER:
 	case NETDEV_RESEND_IGMP:
 	case NETDEV_CHANGEINFODATA:
-	case NETDEV_CHANGELOWERSTATE:
 	case NETDEV_CHANGE_TX_QUEUE_LEN:
 		rtmsg_ifinfo(RTM_NEWLINK, dev, 0, GFP_KERNEL);
 		break;
-- 
2.1.4
