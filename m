From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] drivers/net/appletalk/: make 2 firmware images static const
Date: Tue, 19 Apr 2005 04:36:50 +0200
Message-ID: <20050419023650.GS5489@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261205AbVDSCgz@vger.kernel.org>
To: acme@conectiva.com.br
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes two needlessly global fimware images static const.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 drivers/net/appletalk/cops_ffdrv.h |    2 +-
 drivers/net/appletalk/cops_ltdrv.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

--- linux-2.6.12-rc2-mm3-full/drivers/net/appletalk/cops_ffdrv.h.old	2005-04-19 03:02:05.000000000 +0200
+++ linux-2.6.12-rc2-mm3-full/drivers/net/appletalk/cops_ffdrv.h	2005-04-19 03:02:15.000000000 +0200
@@ -28,7 +28,7 @@
 
 #ifdef CONFIG_COPS_DAYNA
 
-unsigned char ffdrv_code[] = {
+static const unsigned char ffdrv_code[] = {
 	58,3,0,50,228,149,33,255,255,34,226,149,
 	249,17,40,152,33,202,154,183,237,82,77,68,
 	11,107,98,19,54,0,237,176,175,50,80,0,
--- linux-2.6.12-rc2-mm3-full/drivers/net/appletalk/cops_ltdrv.h.old	2005-04-19 03:02:27.000000000 +0200
+++ linux-2.6.12-rc2-mm3-full/drivers/net/appletalk/cops_ltdrv.h	2005-04-19 03:02:34.000000000 +0200
@@ -27,7 +27,7 @@
 
 #ifdef CONFIG_COPS_TANGENT
 
-unsigned char ltdrv_code[] = {
+static const unsigned char ltdrv_code[] = {
 	58,3,0,50,148,10,33,143,15,62,85,119,
 	190,32,9,62,170,119,190,32,3,35,24,241,
 	34,146,10,249,17,150,10,33,143,15,183,237,
