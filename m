From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v2 5/8] rtnetlink: Do not generate notifications for PRECHANGEUPPER event
Date: Tue, 11 Apr 2017 17:02:44 -0700
Message-ID: <1491955367-12443-6-git-send-email-dsa@cumulusnetworks.com>
References: <1491955367-12443-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:35954 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753049AbdDLAC4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 20:02:56 -0400
Received: by mail-pg0-f50.google.com with SMTP id g2so5754603pge.3
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 17:02:56 -0700 (PDT)
In-Reply-To: <1491955367-12443-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PRECHANGEUPPER is an internal event; do not generate userspace
notifications.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/core/rtnetlink.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 8cfb9e3c1f6e..10df445bb818 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -4124,7 +4124,6 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 	case NETDEV_CHANGEUPPER:
 	case NETDEV_RESEND_IGMP:
 	case NETDEV_CHANGEINFODATA:
-	case NETDEV_PRECHANGEUPPER:
 	case NETDEV_CHANGELOWERSTATE:
 	case NETDEV_CHANGE_TX_QUEUE_LEN:
 		rtmsg_ifinfo(RTM_NEWLINK, dev, 0, GFP_KERNEL);
-- 
2.1.4
