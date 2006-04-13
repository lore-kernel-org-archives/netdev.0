From: Erik Mouw <erik@harddisk-recovery.com>
Subject: [PATCH] bcm43xx: iw_priv_args names should be <16 characters
Date: Thu, 13 Apr 2006 15:02:27 +0200
Message-ID: <20060413130227.GD20839@harddisk-recovery.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dtp.xs4all.nl ([80.126.206.180]:7113 "HELO abra2.bitwizard.nl")
	by vger.kernel.org with SMTP id S964908AbWDMNC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2006 09:02:29 -0400
To: bcm43xx-dev@lists.berlios.de
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The room for the names in bcm43xx_priv_wx_args[] are IFNAMSIZ long and
IFNAMSIZ is defined as 16, so the names in bcm43xx_priv_wx_args should
be 15 characters (16 including the trailing \0). This patch fixes that
for the "set_shortpreambl", "get_shortpreambl", "set_swencryption", and
"get_swencryption" private calls. Patch is against 2.6.17-rc1.

Signed-off-by: Erik Mouw <erik@harddisk-recovery.com>

diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_wx.c b/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
index 3daee82..3edbb48 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
@@ -962,22 +962,22 @@ static const struct iw_priv_args bcm43xx
 	{
 		.cmd		= PRIV_WX_SET_SHORTPREAMBLE,
 		.set_args	= IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-		.name		= "set_shortpreambl",
+		.name		= "set_shortpreamb",
 	},
 	{
 		.cmd		= PRIV_WX_GET_SHORTPREAMBLE,
 		.get_args	= IW_PRIV_TYPE_CHAR | IW_PRIV_SIZE_FIXED | MAX_WX_STRING,
-		.name		= "get_shortpreambl",
+		.name		= "get_shortpreamb",
 	},
 	{
 		.cmd		= PRIV_WX_SET_SWENCRYPTION,
 		.set_args	= IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-		.name		= "set_swencryption",
+		.name		= "set_swencrypt",
 	},
 	{
 		.cmd		= PRIV_WX_GET_SWENCRYPTION,
 		.get_args	= IW_PRIV_TYPE_CHAR | IW_PRIV_SIZE_FIXED | MAX_WX_STRING,
-		.name		= "get_swencryption",
+		.name		= "get_swencrypt",
 	},
 	{
 		.cmd		= PRIV_WX_SPROM_WRITE,
