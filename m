From: "=?ISO-8859-1?Q?Miguel_=C1ngel_=C1lvarez?=" <gotzoncabanes@gmail.com>
Subject: ixp4xx_hss. Little bug in hss_init_one
Date: Wed, 26 Nov 2008 18:13:06 +0100
Message-ID: <b0438a630811260913t638343a4i5576292b367c5dc2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, "Krzysztof Halasa" <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.29]:15749 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754747AbYKZRSM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 12:18:12 -0500
Received: by yw-out-2324.google.com with SMTP id 9so281174ywe.1
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2008 09:18:10 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I have found that platform_set_drvdata is not correctly called if we
have an error in requesting npe. Am I right?

Signed-off-by: Miguel =C1ngel =C1lvarez (gotzoncabanes@gmail.com)
---
--- ixp4xx_hss.c.orig	2008-11-19 11:26:54.000000000 +0100
+++ ixp4xx_hss.c.initone	2008-11-26 18:09:22.000000000 +0100
@@ -2698,8 +2698,8 @@
 	free_netdev(dev);
 err_plat:
 	npe_release(port->npe);
-	platform_set_drvdata(pdev, NULL);
 err_free:
+	platform_set_drvdata(pdev, NULL);
 	kfree(port);
 	return err;
 }

Thanks

Miguel =C1ngel =C1lvarez
