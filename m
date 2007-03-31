From: Adrian Bunk <bunk@stusta.de>
Subject: [-mm patch] make drivers/net/qla3xxx.c:PHY_DEVICES[] static
Date: Sat, 31 Mar 2007 22:55:40 +0200
Message-ID: <20070331205540.GB14134@stusta.de>
References: <20070330010559.2a232d9a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>, linux-driver@qlogic.com,
	jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:39488 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751894AbXCaUzk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Mar 2007 16:55:40 -0400
Content-Disposition: inline
In-Reply-To: <20070330010559.2a232d9a.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 30, 2007 at 01:05:59AM -0700, Andrew Morton wrote:
>...
> Changes since 2.6.21-rc5-mm2:
>...
>  git-netdev-all.patch
>...
>  git trees
>...


This patch makes the needlessly global PHY_DEVICES[] static.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

BTW: Why is the name uppercase?

--- linux-2.6.21-rc5-mm3/drivers/net/qla3xxx.c.old	2007-03-31 21:30:20.000000000 +0200
+++ linux-2.6.21-rc5-mm3/drivers/net/qla3xxx.c	2007-03-31 22:02:00.000000000 +0200
@@ -88,7 +88,7 @@
 	char 		*name;
 } PHY_DEVICE_INFO_t;
 
-const PHY_DEVICE_INFO_t PHY_DEVICES[] =
+static const PHY_DEVICE_INFO_t PHY_DEVICES[] =
 	{{PHY_TYPE_UNKNOWN,    0x000000, 0x0, "PHY_TYPE_UNKNOWN"},
 	 {PHY_VITESSE_VSC8211, 0x0003f1, 0xb, "PHY_VITESSE_VSC8211"},
 	 {PHY_AGERE_ET1011C,   0x00a0bc, 0x1, "PHY_AGERE_ET1011C"},
