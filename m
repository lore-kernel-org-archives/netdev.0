From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] doc: fix some syntax errors in netlink mmap sample code
Date: Mon, 24 Jun 2013 19:46:54 +0800
Message-ID: <1372074414-11639-1-git-send-email-amwang@redhat.com>
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52657 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751952Ab3FXLrF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jun 2013 07:47:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>


Cc: Patrick McHardy <kaber@trash.net>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
diff --git a/Documentation/networking/netlink_mmap.txt b/Documentation/networking/netlink_mmap.txt
index e6088ba..5cc6005 100644
--- a/Documentation/networking/netlink_mmap.txt
+++ b/Documentation/networking/netlink_mmap.txt
@@ -274,9 +274,9 @@ This example assumes some ring parameters of the ring setup are available.
 			/* Get next frame header */
 			hdr = rx_ring + frame_offset;
 
-			if (hdr->nm_status == NL_MMAP_STATUS_VALID)
+			if (hdr->nm_status == NL_MMAP_STATUS_VALID) {
 				/* Regular memory mapped frame */
-				nlh = (void *hdr) + NL_MMAP_HDRLEN;
+				nlh = (void *)hdr + NL_MMAP_HDRLEN;
 				len = hdr->nm_len;
 
 				/* Release empty message immediately. May happen
