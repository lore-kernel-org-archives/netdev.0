From: "Aubrey Li" <aubreylee@gmail.com>
Subject: [PATCH] CONFIG_PACKET_MMAP should depend on MMU
Date: Mon, 9 Apr 2007 11:01:01 +0800
Message-ID: <6d6a94c50704082001y5c13c865ic3d70217aba7d181@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Linux Kernel" <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org, "Andrew Morton" <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.227]:41228 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752437AbXDIDBC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Apr 2007 23:01:02 -0400
Received: by nz-out-0506.google.com with SMTP id s1so942853nze
        for <netdev@vger.kernel.org>; Sun, 08 Apr 2007 20:01:01 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The option CONFIG_PACKET_MMAP should depend on MMU.

Signed-off-by: Aubrey.Li <aubreylee@gmail.com>
---
 net/packet/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/packet/Kconfig b/net/packet/Kconfig
index 34ff93f..959c272 100644
--- a/net/packet/Kconfig
+++ b/net/packet/Kconfig
@@ -17,7 +17,7 @@ config PACKET

 config PACKET_MMAP
 	bool "Packet socket: mmapped IO"
-	depends on PACKET
+	depends on PACKET && MMU
 	help
 	  If you say Y here, the Packet protocol driver will use an IO
 	  mechanism that results in faster communication.
-- 
1.5.1
