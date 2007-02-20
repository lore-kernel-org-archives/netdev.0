From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 2/3] forcedeth: disable msix
Date: Tue, 20 Feb 2007 03:34:40 -0500
Message-ID: <45DAB2A0.2020004@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040100000506040002060903"
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate01.nvidia.com ([216.228.112.170]:2087 "EHLO
	HQEMGATE01.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030358AbXBTSw0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Feb 2007 13:52:26 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040100000506040002060903
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

There seems to be an issue when both MSI-X is enabled and NAPI is 
configured. This patch disables MSI-X until the issue is root caused.

Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>


--------------040100000506040002060903
Content-Type: text/plain;
 name="patch-forcedeth-msix"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-msix"

--- orig/drivers/net/forcedeth.c	2007-02-20 03:29:04.000000000 -0500
+++ new/drivers/net/forcedeth.c	2007-02-20 03:29:33.000000000 -0500
@@ -839,7 +839,7 @@
 	NV_MSIX_INT_DISABLED,
 	NV_MSIX_INT_ENABLED
 };
-static int msix = NV_MSIX_INT_ENABLED;
+static int msix = NV_MSIX_INT_DISABLED;
 
 /*
  * DMA 64bit

--------------040100000506040002060903--
