From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 1/15] netdevice: safe convert to netdev_priv() #part-16
Date: Tue, 26 Aug 2008 22:19:22 +0800
Message-ID: <48B410EA.50103@cn.fujitsu.com>
References: <48B3D717.7070706@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57096 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757217AbYHZOVu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2008 10:21:50 -0400
In-Reply-To: <48B3D717.7070706@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
diff --git a/drivers/net/wireless/libertas/wext.c b/drivers/net/wireless/libertas/wext.c
index 8b3ed77..c9b2331 100644
--- a/drivers/net/wireless/libertas/wext.c
+++ b/drivers/net/wireless/libertas/wext.c
@@ -183,7 +183,7 @@ static int lbs_get_name(struct net_device *dev, struct iw_request_info *info,
 static int lbs_get_freq(struct net_device *dev, struct iw_request_info *info,
 			 struct iw_freq *fwrq, char *extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	struct chan_freq_power *cfp;
 
 	lbs_deb_enter(LBS_DEB_WEXT);
@@ -209,7 +209,7 @@ static int lbs_get_freq(struct net_device *dev, struct iw_request_info *info,
 static int lbs_get_wap(struct net_device *dev, struct iw_request_info *info,
 			struct sockaddr *awrq, char *extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -227,7 +227,7 @@ static int lbs_get_wap(struct net_device *dev, struct iw_request_info *info,
 static int lbs_set_nick(struct net_device *dev, struct iw_request_info *info,
 			 struct iw_point *dwrq, char *extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -251,7 +251,7 @@ static int lbs_set_nick(struct net_device *dev, struct iw_request_info *info,
 static int lbs_get_nick(struct net_device *dev, struct iw_request_info *info,
 			 struct iw_point *dwrq, char *extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -268,7 +268,7 @@ static int lbs_get_nick(struct net_device *dev, struct iw_request_info *info,
 static int mesh_get_nick(struct net_device *dev, struct iw_request_info *info,
 			 struct iw_point *dwrq, char *extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -293,7 +293,7 @@ static int lbs_set_rts(struct net_device *dev, struct iw_request_info *info,
 			struct iw_param *vwrq, char *extra)
 {
 	int ret = 0;
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	u32 rthr = vwrq->value;
 
 	lbs_deb_enter(LBS_DEB_WEXT);
@@ -318,7 +318,7 @@ static int lbs_get_rts(struct net_device *dev, struct iw_request_info *info,
 			struct iw_param *vwrq, char *extra)
 {
 	int ret = 0;
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -344,7 +344,7 @@ static int lbs_set_frag(struct net_device *dev, struct iw_request_info *info,
 {
 	int ret = 0;
 	u32 fthr = vwrq->value;
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -369,7 +369,7 @@ static int lbs_get_frag(struct net_device *dev, struct iw_request_info *info,
 			 struct iw_param *vwrq, char *extra)
 {
 	int ret = 0;
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -394,7 +394,7 @@ out:
 static int lbs_get_mode(struct net_device *dev,
 			 struct iw_request_info *info, u32 * uwrq, char *extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -421,7 +421,7 @@ static int lbs_get_txpow(struct net_device *dev,
 			  struct iw_param *vwrq, char *extra)
 {
 	int ret = 0;
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -452,7 +452,7 @@ static int lbs_set_retry(struct net_device *dev, struct iw_request_info *info,
 			  struct iw_param *vwrq, char *extra)
 {
 	int ret = 0;
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -486,7 +486,7 @@ out:
 static int lbs_get_retry(struct net_device *dev, struct iw_request_info *info,
 			  struct iw_param *vwrq, char *extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	int ret = 0;
 
 	lbs_deb_enter(LBS_DEB_WEXT);
@@ -554,7 +554,7 @@ static int lbs_get_range(struct net_device *dev, struct iw_request_info *info,
 			  struct iw_point *dwrq, char *extra)
 {
 	int i, j;
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	struct iw_range *range = (struct iw_range *)extra;
 	struct chan_freq_power *cfp;
 	u8 rates[MAX_RATES + 1];
@@ -730,7 +730,7 @@ out:
 static int lbs_set_power(struct net_device *dev, struct iw_request_info *info,
 			  struct iw_param *vwrq, char *extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -780,7 +780,7 @@ static int lbs_set_power(struct net_device *dev, struct iw_request_info *info,
 static int lbs_get_power(struct net_device *dev, struct iw_request_info *info,
 			  struct iw_param *vwrq, char *extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -803,7 +803,7 @@ static struct iw_statistics *lbs_get_wireless_stats(struct net_device *dev)
 		EXCELLENT = 95,
 		PERFECT = 100
 	};
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	u32 rssi_qual;
 	u32 tx_qual;
 	u32 quality = 0;
@@ -908,7 +908,7 @@ static int lbs_set_freq(struct net_device *dev, struct iw_request_info *info,
 		  struct iw_freq *fwrq, char *extra)
 {
 	int ret = -EINVAL;
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	struct chan_freq_power *cfp;
 	struct assoc_request * assoc_req;
 
@@ -965,7 +965,7 @@ static int lbs_mesh_set_freq(struct net_device *dev,
 			     struct iw_request_info *info,
 			     struct iw_freq *fwrq, char *extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	struct chan_freq_power *cfp;
 	int ret = -EINVAL;
 
@@ -1014,7 +1014,7 @@ out:
 static int lbs_set_rate(struct net_device *dev, struct iw_request_info *info,
 		  struct iw_param *vwrq, char *extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	u8 new_rate = 0;
 	int ret = -EINVAL;
 	u8 rates[MAX_RATES + 1];
@@ -1062,7 +1062,7 @@ out:
 static int lbs_get_rate(struct net_device *dev, struct iw_request_info *info,
 		  struct iw_param *vwrq, char *extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -1087,7 +1087,7 @@ static int lbs_set_mode(struct net_device *dev,
 		  struct iw_request_info *info, u32 * uwrq, char *extra)
 {
 	int ret = 0;
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	struct assoc_request * assoc_req;
 
 	lbs_deb_enter(LBS_DEB_WEXT);
@@ -1132,7 +1132,7 @@ static int lbs_get_encode(struct net_device *dev,
 			   struct iw_request_info *info,
 			   struct iw_point *dwrq, u8 * extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	int index = (dwrq->flags & IW_ENCODE_INDEX) - 1;
 
 	lbs_deb_enter(LBS_DEB_WEXT);
@@ -1327,7 +1327,7 @@ static int lbs_set_encode(struct net_device *dev,
 		    struct iw_point *dwrq, char *extra)
 {
 	int ret = 0;
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	struct assoc_request * assoc_req;
 	u16 is_default = 0, index = 0, set_tx_key = 0;
 
@@ -1403,7 +1403,7 @@ static int lbs_get_encodeext(struct net_device *dev,
 			      char *extra)
 {
 	int ret = -EINVAL;
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	struct iw_encode_ext *ext = (struct iw_encode_ext *)extra;
 	int index, max_key_len;
 
@@ -1509,7 +1509,7 @@ static int lbs_set_encodeext(struct net_device *dev,
 			      char *extra)
 {
 	int ret = 0;
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	struct iw_encode_ext *ext = (struct iw_encode_ext *)extra;
 	int alg = ext->alg;
 	struct assoc_request * assoc_req;
@@ -1633,7 +1633,7 @@ static int lbs_set_genie(struct net_device *dev,
 			  struct iw_point *dwrq,
 			  char *extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	int ret = 0;
 	struct assoc_request * assoc_req;
 
@@ -1679,7 +1679,7 @@ static int lbs_get_genie(struct net_device *dev,
 			  char *extra)
 {
 	int ret = 0;
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -1707,7 +1707,7 @@ static int lbs_set_auth(struct net_device *dev,
 			 struct iw_param *dwrq,
 			 char *extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	struct assoc_request * assoc_req;
 	int ret = 0;
 	int updated = 0;
@@ -1806,7 +1806,7 @@ static int lbs_get_auth(struct net_device *dev,
 			 char *extra)
 {
 	int ret = 0;
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -1843,7 +1843,7 @@ static int lbs_set_txpow(struct net_device *dev, struct iw_request_info *info,
 		   struct iw_param *vwrq, char *extra)
 {
 	int ret = 0;
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	u16 dbm;
 
@@ -1884,7 +1884,7 @@ static int lbs_set_txpow(struct net_device *dev, struct iw_request_info *info,
 static int lbs_get_essid(struct net_device *dev, struct iw_request_info *info,
 		   struct iw_point *dwrq, char *extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -1919,7 +1919,7 @@ static int lbs_get_essid(struct net_device *dev, struct iw_request_info *info,
 static int lbs_set_essid(struct net_device *dev, struct iw_request_info *info,
 		   struct iw_point *dwrq, char *extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	int ret = 0;
 	u8 ssid[IW_ESSID_MAX_SIZE];
 	u8 ssid_len = 0;
@@ -1982,7 +1982,7 @@ static int lbs_mesh_get_essid(struct net_device *dev,
 			      struct iw_request_info *info,
 			      struct iw_point *dwrq, char *extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -2000,7 +2000,7 @@ static int lbs_mesh_set_essid(struct net_device *dev,
 			      struct iw_request_info *info,
 			      struct iw_point *dwrq, char *extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	int ret = 0;
 
 	lbs_deb_enter(LBS_DEB_WEXT);
@@ -2039,7 +2039,7 @@ static int lbs_mesh_set_essid(struct net_device *dev,
 static int lbs_set_wap(struct net_device *dev, struct iw_request_info *info,
 		 struct sockaddr *awrq, char *extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	struct assoc_request * assoc_req;
 	int ret = 0;
 	DECLARE_MAC_BUF(mac);
diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index 00e965b..9d7630c 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -1104,7 +1104,7 @@ static int rndis_iw_get_range(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
 	struct iw_range *range = (struct iw_range *)extra;
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
 	int len, ret, i, j, num, has_80211g_rates;
 	u8 rates[8];
@@ -1210,7 +1210,7 @@ static int rndis_iw_get_range(struct net_device *dev,
 static int rndis_iw_get_name(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
 
 	strcpy(wrqu->name, priv->name);
@@ -1223,7 +1223,7 @@ static int rndis_iw_set_essid(struct net_device *dev,
 {
 	struct ndis_80211_ssid ssid;
 	int length = wrqu->essid.length;
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 
 	devdbg(usbdev, "SIOCSIWESSID: [flags:%d,len:%d] '%.32s'",
 		wrqu->essid.flags, wrqu->essid.length, essid);
@@ -1250,7 +1250,7 @@ static int rndis_iw_get_essid(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *essid)
 {
 	struct ndis_80211_ssid ssid;
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	int ret;
 
 	ret = get_essid(usbdev, &ssid);
@@ -1273,7 +1273,7 @@ static int rndis_iw_get_essid(struct net_device *dev,
 static int rndis_iw_get_bssid(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	unsigned char bssid[ETH_ALEN];
 	int ret;
 	DECLARE_MAC_BUF(mac);
@@ -1295,7 +1295,7 @@ static int rndis_iw_get_bssid(struct net_device *dev,
 static int rndis_iw_set_bssid(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	u8 *bssid = (u8 *)wrqu->ap_addr.sa_data;
 	DECLARE_MAC_BUF(mac);
 	int ret;
@@ -1318,7 +1318,7 @@ static int rndis_iw_set_auth(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
 	struct iw_param *p = &wrqu->param;
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
 	int ret = -ENOTSUPP;
 
@@ -1399,7 +1399,7 @@ static int rndis_iw_get_auth(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
 	struct iw_param *p = &wrqu->param;
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
 
 	switch (p->flags & IW_AUTH_INDEX) {
@@ -1431,7 +1431,7 @@ static int rndis_iw_get_mode(struct net_device *dev,
 				struct iw_request_info *info,
 				union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
 
 	switch (priv->infra_mode) {
@@ -1454,7 +1454,7 @@ static int rndis_iw_get_mode(struct net_device *dev,
 static int rndis_iw_set_mode(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	int mode;
 
 	devdbg(usbdev, "SIOCSIWMODE: %08x", wrqu->mode);
@@ -1479,7 +1479,7 @@ static int rndis_iw_set_mode(struct net_device *dev,
 static int rndis_iw_set_encode(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
 	int ret, index, key_len;
 	u8 *key;
@@ -1542,7 +1542,7 @@ static int rndis_iw_set_encode_ext(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
 	struct iw_encode_ext *ext = (struct iw_encode_ext *)extra;
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
 	struct ndis_80211_key ndis_key;
 	int keyidx, ret;
@@ -1628,7 +1628,7 @@ static int rndis_iw_set_scan(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
 	struct iw_param *param = &wrqu->param;
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	union iwreq_data evt;
 	int ret = -EINVAL;
 	__le32 tmp;
@@ -1653,7 +1653,7 @@ static char *rndis_translate_scan(struct net_device *dev,
 				  struct ndis_80211_bssid_ex *bssid)
 {
 #ifdef DEBUG
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 #endif
 	struct ieee80211_info_element *ie;
 	char *current_val;
@@ -1777,7 +1777,7 @@ static char *rndis_translate_scan(struct net_device *dev,
 static int rndis_iw_get_scan(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	void *buf = NULL;
 	char *cev = extra;
 	struct ndis_80211_bssid_list_ex *bssid_list;
@@ -1823,7 +1823,7 @@ out:
 static int rndis_iw_set_genie(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
 	int ret = 0;
 
@@ -1857,7 +1857,7 @@ static int rndis_iw_set_genie(struct net_device *dev,
 static int rndis_iw_get_genie(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
 
 	devdbg(usbdev, "SIOCGIWGENIE");
@@ -1880,7 +1880,7 @@ static int rndis_iw_get_genie(struct net_device *dev,
 static int rndis_iw_set_rts(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	__le32 tmp;
 	devdbg(usbdev, "SIOCSIWRTS");
 
@@ -1893,7 +1893,7 @@ static int rndis_iw_set_rts(struct net_device *dev,
 static int rndis_iw_get_rts(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	__le32 tmp;
 	int len, ret;
 
@@ -1914,7 +1914,7 @@ static int rndis_iw_get_rts(struct net_device *dev,
 static int rndis_iw_set_frag(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	__le32 tmp;
 
 	devdbg(usbdev, "SIOCSIWFRAG");
@@ -1928,7 +1928,7 @@ static int rndis_iw_set_frag(struct net_device *dev,
 static int rndis_iw_get_frag(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	__le32 tmp;
 	int len, ret;
 
@@ -1948,7 +1948,7 @@ static int rndis_iw_get_frag(struct net_device *dev,
 static int rndis_iw_set_nick(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
 
 	devdbg(usbdev, "SIOCSIWNICK");
@@ -1965,7 +1965,7 @@ static int rndis_iw_set_nick(struct net_device *dev,
 static int rndis_iw_get_nick(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
 
 	wrqu->data.flags = 1;
@@ -1981,7 +1981,7 @@ static int rndis_iw_get_nick(struct net_device *dev,
 static int rndis_iw_set_freq(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	struct ndis_80211_conf config;
 	unsigned int dsconfig;
 	int len, ret;
@@ -2012,7 +2012,7 @@ static int rndis_iw_set_freq(struct net_device *dev,
 static int rndis_iw_get_freq(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	struct ndis_80211_conf config;
 	int len, ret;
 
@@ -2029,7 +2029,7 @@ static int rndis_iw_get_freq(struct net_device *dev,
 static int rndis_iw_get_txpower(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
 	__le32 tx_power;
 	int ret = 0, len;
@@ -2063,7 +2063,7 @@ static int rndis_iw_get_txpower(struct net_device *dev,
 static int rndis_iw_set_txpower(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
 	__le32 tx_power = 0;
 	int ret = 0;
@@ -2115,7 +2115,7 @@ static int rndis_iw_set_txpower(struct net_device *dev,
 static int rndis_iw_get_rate(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	__le32 tmp;
 	int ret, len;
 
@@ -2133,7 +2133,7 @@ static int rndis_iw_get_rate(struct net_device *dev,
 static int rndis_iw_set_mlme(struct net_device *dev,
     struct iw_request_info *info, union iwreq_data *wrqu, char *extra)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
 	struct iw_mlme *mlme = (struct iw_mlme *)extra;
 	unsigned char bssid[ETH_ALEN];
@@ -2158,7 +2158,7 @@ static int rndis_iw_set_mlme(struct net_device *dev,
 
 static struct iw_statistics *rndis_get_wireless_stats(struct net_device *dev)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
 	unsigned long flags;
 
@@ -2288,7 +2288,7 @@ get_bssid:
 
 static void rndis_wext_set_multicast_list(struct net_device *dev)
 {
-	struct usbnet *usbdev = dev->priv;
+	struct usbnet *usbdev = netdev_priv(dev);
 	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
 
 	if (test_bit(WORK_SET_MULTICAST_LIST, &priv->work_pending))


