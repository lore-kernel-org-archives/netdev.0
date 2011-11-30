From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH] caif: Remove unused attributes from struct cflayer
Date: Thu,  1 Dec 2011 00:02:32 +0100
Message-ID: <1322694152-5422-1-git-send-email-sjur.brandeland@stericsson.com>
References: <20111130.170457.1002117290486935116.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:61062 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752107Ab1K3XCs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 18:02:48 -0500
Received: by eaak14 with SMTP id k14so1346741eaa.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 15:02:47 -0800 (PST)
In-Reply-To: <20111130.170457.1002117290486935116.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
Hi Dave,

>...
>Looks like this code was always buggy, passing the index in the type p=
arameter
>and the type in the instance parameter.
>

Yes, you're right. The type and prio isn't used anyway,
so let's just kill it off.

Regards,
Sjur

 include/net/caif/caif_layer.h |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/include/net/caif/caif_layer.h b/include/net/caif/caif_laye=
r.h
index 35bc788..0f3a391 100644
--- a/include/net/caif/caif_layer.h
+++ b/include/net/caif/caif_layer.h
@@ -121,9 +121,7 @@ enum caif_direction {
  * @transmit:	Packet transmit funciton.
  * @ctrlcmd:	Used for control signalling upwards in the stack.
  * @modemcmd:	Used for control signaling downwards in the stack.
- * @prio:	Priority of this layer.
  * @id:		The identity of this layer
- * @type:	The type of this layer
  * @name:	Name of the layer.
  *
  *  This structure defines the layered structure in CAIF.
@@ -230,9 +228,7 @@ struct cflayer {
 	 */
 	int (*modemcmd) (struct cflayer *layr, enum caif_modemcmd ctrl);
=20
-	unsigned short prio;
 	unsigned int id;
-	unsigned int type;
 	char name[CAIF_LAYER_NAME_SZ];
 };
=20
--=20
1.7.0.4
