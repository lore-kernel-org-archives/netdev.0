From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 14/14] batman-adv: drop dependency against CRC16
Date: Mon, 13 Jan 2014 23:31:38 +0100
Message-ID: <1389652298-472-15-git-send-email-antonio@meshcoding.com>
References: <1389652298-472-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:35898 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751388AbaAMWyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 17:54:13 -0500
In-Reply-To: <1389652298-472-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The crc16 functionality is not used anymore, therefore
we can safely remove the dependency in the Kbuild file.

Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/Kconfig | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/batman-adv/Kconfig b/net/batman-adv/Kconfig
index fa780b7..2b2dc47 100644
--- a/net/batman-adv/Kconfig
+++ b/net/batman-adv/Kconfig
@@ -5,7 +5,6 @@
 config BATMAN_ADV
 	tristate "B.A.T.M.A.N. Advanced Meshing Protocol"
 	depends on NET
-	select CRC16
 	select LIBCRC32C
         default n
 	help
-- 
1.8.5.2
