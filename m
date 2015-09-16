From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] man ip-link: Fix wording in VLAN reorder_hdr explanation
Date: Wed, 16 Sep 2015 19:55:19 +0300
Message-ID: <1442422519-12679-1-git-send-email-vadim4j@gmail.com>
Cc: jgh@redhat.com, Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:35541 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752778AbbIPQ6h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2015 12:58:37 -0400
Received: by wicge5 with SMTP id ge5so83515221wic.0
        for <netdev@vger.kernel.org>; Wed, 16 Sep 2015 09:58:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 man/man8/ip-link.8.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 1896eb6..4928249 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -327,7 +327,7 @@ physical device (if this device does not support VLAN offloading), the similar
 on the RX direction - by default the packet will be untagged before being
 received by VLAN device. Reordering allows to accelerate tagging on egress and
 to hide VLAN header on ingress so the packet looks like regular Ethernet packet,
-at the same time it might be confusing while the packet sniffing as the VLAN header
+at the same time it might be confusing for packet capture as the VLAN header
 does not exist within the packet.
 
 VLAN offloading can be checked by
-- 
2.4.2
