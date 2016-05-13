From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 2/2] lxt: simplify lxt970_config_init()
Date: Sat, 14 May 2016 02:09:07 +0300
Message-ID: <10461460.oZtY7gCKIq@wasted.cogentembedded.com>
References: <15412071.hrgkzMpf1A@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: f.fainelli@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:34624 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932363AbcEMXJL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 19:09:11 -0400
Received: by mail-lb0-f179.google.com with SMTP id n11so31281839lbh.1
        for <netdev@vger.kernel.org>; Fri, 13 May 2016 16:09:10 -0700 (PDT)
In-Reply-To: <15412071.hrgkzMpf1A@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function declares the 'err' local variable for no good reason, get rid
of it.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/phy/lxt.c |    6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

Index: net-next/drivers/net/phy/lxt.c
===================================================================
--- net-next.orig/drivers/net/phy/lxt.c
+++ net-next/drivers/net/phy/lxt.c
@@ -88,11 +88,7 @@ static int lxt970_config_intr(struct phy
 
 static int lxt970_config_init(struct phy_device *phydev)
 {
-	int err;
-
-	err = phy_write(phydev, MII_LXT970_CONFIG, 0);
-
-	return err;
+	return phy_write(phydev, MII_LXT970_CONFIG, 0);
 }
 
 
