From: Michal Schmidt <mschmidt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/3] airo: Don't check for NULL before kfree()
Date: Fri, 16 Mar 2007 12:40:00 +0100
Message-ID: <45FA8210.7080709@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: breed-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

It's unnecessary to check for NULL before calling kfree().

Signed-off-by: Michal Schmidt <mschmidt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index a8c2bfe..71ac1f1 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -2740,8 +2740,6 @@ static int airo_networks_allocate(struct airo_info *ai)
 
 static void airo_networks_free(struct airo_info *ai)
 {
-	if (!ai->networks)
-		return;
 	kfree(ai->networks);
 	ai->networks = NULL;
 }
