From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 3/3] hostap: Delete unnecessary initialisations for the
 variable "ret"
Date: Sat, 20 Aug 2016 18:48:13 +0200
Message-ID: <f1de4eb1-42e7-0124-89a2-c1e7fdf7053c@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
 <f0cd7a82-e603-6a91-0afd-33bbd1658cab@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        Jouni Malinen <j@w1.fi>, Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <f0cd7a82-e603-6a91-0afd-33bbd1658cab@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 20 Aug 2016 18:23:14 +0200

The local variable "ret" will be set to an appropriate value a bit later.
Thus omit the explicit initialisation at the beginning of four functions.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/wireless/intersil/hostap/hostap_ioctl.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/intersil/hostap/hostap_ioctl.c b/drivers/net/wireless/intersil/hostap/hostap_ioctl.c
index 5942917..c37b0bb 100644
--- a/drivers/net/wireless/intersil/hostap/hostap_ioctl.c
+++ b/drivers/net/wireless/intersil/hostap/hostap_ioctl.c
@@ -2895,7 +2895,7 @@ static int prism2_ioctl_priv_monitor(struct net_device *dev, int *i)
 {
 	struct hostap_interface *iface;
 	local_info_t *local;
-	int ret = 0;
+	int ret;
 	u32 mode;
 
 	iface = netdev_priv(dev);
@@ -3035,7 +3035,7 @@ static int ap_mac_cmd_ioctl(local_info_t *local, int *cmd)
 static int prism2_ioctl_priv_download(local_info_t *local, struct iw_point *p)
 {
 	struct prism2_download_param *param;
-	int ret = 0;
+	int ret;
 
 	if (p->length < sizeof(struct prism2_download_param) ||
 	    p->length > 1024 || !p->pointer)
@@ -3791,7 +3791,7 @@ static int prism2_ioctl_scan_req(local_info_t *local,
 static int prism2_ioctl_priv_hostapd(local_info_t *local, struct iw_point *p)
 {
 	struct prism2_hostapd_param *param;
-	int ret = 0;
+	int ret;
 	int ap_ioctl = 0;
 
 	if (p->length < sizeof(struct prism2_hostapd_param) ||
@@ -3954,7 +3954,7 @@ int hostap_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	struct iwreq *wrq = (struct iwreq *) ifr;
 	struct hostap_interface *iface;
 	local_info_t *local;
-	int ret = 0;
+	int ret;
 
 	iface = netdev_priv(dev);
 	local = iface->local;
-- 
2.9.3
