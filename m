From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [PATCH net-next 10/10] pktgen: Correct documentation of module name
 and command
Date: Tue, 24 Feb 2015 02:33:29 +0000
Message-ID: <1424745209.4443.11.camel@xylophone.i.decadent.org.uk>
References: <1424745019.4443.1.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@lists.codethink.co.uk
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:55454 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752284AbbBXCdb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 21:33:31 -0500
In-Reply-To: <1424745019.4443.1.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drop the '.o' suffix so this text properly covers both the
built-in and modular cases.

'insmod pktgen' obviously won't work; the command should be modprobe.

Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
---
 Documentation/networking/pktgen.txt |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/pktgen.txt b/Documentation/networking/pktgen.txt
index 24c6dc100e02..0344f1d45b37 100644
--- a/Documentation/networking/pktgen.txt
+++ b/Documentation/networking/pktgen.txt
@@ -3,8 +3,8 @@
                   HOWTO for the linux packet generator 
                   ------------------------------------
 
-Enable CONFIG_NET_PKTGEN to compile and build pktgen.o either in-kernel
-or as a module.  A module is preferred; insmod pktgen if needed.  Once
+Enable CONFIG_NET_PKTGEN to compile and build pktgen either in-kernel
+or as a module.  A module is preferred; modprobe pktgen if needed.  Once
 running, pktgen creates a thread for each CPU with affinity to that CPU.
 Monitoring and controlling is done via /proc.  It is easiest to select a
 suitable sample script and configure that.
-- 
1.7.10.4
