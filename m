From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next] vxlan: Correct path typo in comment
Date: Thu, 12 Mar 2015 11:00:10 +0900
Message-ID: <1426125610-7903-1-git-send-email-simon.horman@netronome.com>
Cc: Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	Simon Horman <simon.horman@netronome.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:34289 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751160AbbCLCA3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 22:00:29 -0400
Received: by pdno5 with SMTP id o5so15975524pdn.1
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 19:00:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Flags are used in the return path rather than the return patch.

Fixes: af33c1adae1e ("vxlan: Eliminate dependency on UDP socket in transmit path")
Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 include/net/vxlan.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index eabd3a0..9564b77 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -130,7 +130,7 @@ struct vxlan_sock {
 #define VXLAN_F_GBP			0x800
 #define VXLAN_F_REMCSUM_NOPARTIAL	0x1000
 
-/* Flags that are used in the receive patch. These flags must match in
+/* Flags that are used in the receive path. These flags must match in
  * order for a socket to be shareable
  */
 #define VXLAN_F_RCV_FLAGS		(VXLAN_F_GBP |			\
-- 
2.1.4
