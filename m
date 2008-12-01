From: akpm@linux-foundation.org
Subject: [patch 2/5] misdn: one handmade ARRAY_SIZE converted
Date: Mon, 01 Dec 2008 14:24:22 -0800
Message-ID: <200812012224.mB1MONvK014950@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	ilpo.jarvinen@helsinki.fi
To: kkeil@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:42973 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751268AbYLAWYx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2008 17:24:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Defined as:

static struct device_attribute element_attributes[] =3D {

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
Cc: Karsten Keil <kkeil@suse.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/isdn/mISDN/dsp_pipeline.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff -puN drivers/isdn/mISDN/dsp_pipeline.c~misdn-one-handmade-array_si=
ze-converted drivers/isdn/mISDN/dsp_pipeline.c
--- a/drivers/isdn/mISDN/dsp_pipeline.c~misdn-one-handmade-array_size-c=
onverted
+++ a/drivers/isdn/mISDN/dsp_pipeline.c
@@ -99,8 +99,7 @@ int mISDN_dsp_element_register(struct mI
 		goto err1;
 	}
=20
-	for (i =3D 0; i < (sizeof(element_attributes)
-		/ sizeof(struct device_attribute)); ++i)
+	for (i =3D 0; i < ARRAY_SIZE(element_attributes); ++i)
 		ret =3D device_create_file(&entry->dev,
 				&element_attributes[i]);
 		if (ret) {
_
