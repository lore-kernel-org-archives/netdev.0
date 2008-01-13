From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 1/5] forcedeth: reset register fix
Date: Sun, 13 Jan 2008 16:02:42 -0500
Message-ID: <478A7C72.8060903@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080606010103080801030105"
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate04.nvidia.com ([216.228.112.152]:16537 "EHLO
	hqemgate04.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751898AbYANWs5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 17:48:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080606010103080801030105
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch fixes the reset register definition from 0x3C to 0x34.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------080606010103080801030105
Content-Type: text/plain;
 name="patch-forcedeth-reset-register"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-reset-register"

--- old/drivers/net/forcedeth.c	2008-01-13 15:00:43.000000000 -0500
+++ new/drivers/net/forcedeth.c	2008-01-13 15:00:48.000000000 -0500
@@ -226,7 +226,7 @@
 #define NVREG_MISC1_HD		0x02
 #define NVREG_MISC1_FORCE	0x3b0f3c
 
-	NvRegMacReset = 0x3c,
+	NvRegMacReset = 0x34,
 #define NVREG_MAC_RESET_ASSERT	0x0F3
 	NvRegTransmitterControl = 0x084,
 #define NVREG_XMITCTL_START	0x01

--------------080606010103080801030105--
