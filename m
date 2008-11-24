From: "=?ISO-8859-1?Q?Miguel_=C1ngel_=C1lvarez?=" <gotzoncabanes@gmail.com>
Subject: [PATCH 1/1] ixp4xx_hss: Non-used lut variable
Date: Mon, 24 Nov 2008 15:37:42 +0100
Message-ID: <b0438a630811240637i3636b297taafa01f4947a4b1c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, "Krzysztof Halasa" <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.241]:16768 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752471AbYKXOhn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 09:37:43 -0500
Received: by an-out-0708.google.com with SMTP id d40so813096and.1
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2008 06:37:42 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

Taking a look to ixp4xx_hss code, I have found a non-used variable in
hss_config_set_lut. I suppose it is part of a deprecated code. This
patch removes it.

Signed-off-by: Miguel =C1ngel =C1lvarez (gotzoncabanes@gmail.com)
---
diff -urN linux-2.6.26.7_hssorig/drivers/net/wan/ixp4xx_hss.c
linux-2.6.26.7_hsspatched/drivers/net/wan/ixp4xx_hss.c
--- linux-2.6.26.7_hssorig/drivers/net/wan/ixp4xx_hss.c	2008-11-24
15:29:27.000000000 +0100
+++ linux-2.6.26.7_hsspatched/drivers/net/wan/ixp4xx_hss.c	2008-11-24
15:33:55.000000000 +0100
@@ -521,9 +521,7 @@
 {
 	struct msg msg;
 	int chan_count =3D 0, log_chan =3D 0, i, ch;
-	u32 lut[MAX_CHANNELS / 4];
-
-	memset(lut, 0, sizeof(lut));
+=09
 	for (i =3D 0; i < MAX_CHAN_DEVICES; i++)
 		if (port->chan_devices[i])
 			port->chan_devices[i]->chan_count =3D 0;

Thanks

Miguel =C1ngel =C1lvarez
