From: Joe Perches <joe@perches.com>
Subject: [PATCH v3 4/9] net/wireless/wext_core.c: Use IW_IOCTL_IDX macro
Date: Thu, 18 Mar 2010 18:29:35 -0700
Message-ID: <785667b2e62b40ddffbe18d9aef5034f83ee7921.1268961559.git.joe@perches.com>
References: <cover.1268961559.git.joe@perches.com>
Cc: Richard Kennedy <richard@rsk.demon.co.uk>,
	Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1865 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754253Ab0CSB3q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Mar 2010 21:29:46 -0400
In-Reply-To: <cover.1268961559.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's a wireless.h macro for this, might as well use it.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/wireless/wext-core.c |  112 +++++++++++++++++++++++-----------------------
 1 files changed, 56 insertions(+), 56 deletions(-)

diff --git a/net/wireless/wext-core.c b/net/wireless/wext-core.c
index 5e1656b..dbde22b 100644
--- a/net/wireless/wext-core.c
+++ b/net/wireless/wext-core.c
@@ -28,226 +28,226 @@ typedef int (*wext_ioctl_func)(struct net_device *, struct iwreq *,
  * know about.
  */
 static const struct iw_ioctl_description standard_ioctl[] = {
-	[SIOCSIWCOMMIT	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCSIWCOMMIT)] = {
 		.header_type	= IW_HEADER_TYPE_NULL,
 	},
-	[SIOCGIWNAME	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCGIWNAME)] = {
 		.header_type	= IW_HEADER_TYPE_CHAR,
 		.flags		= IW_DESCR_FLAG_DUMP,
 	},
-	[SIOCSIWNWID	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCSIWNWID)] = {
 		.header_type	= IW_HEADER_TYPE_PARAM,
 		.flags		= IW_DESCR_FLAG_EVENT,
 	},
-	[SIOCGIWNWID	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCGIWNWID)] = {
 		.header_type	= IW_HEADER_TYPE_PARAM,
 		.flags		= IW_DESCR_FLAG_DUMP,
 	},
-	[SIOCSIWFREQ	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCSIWFREQ)] = {
 		.header_type	= IW_HEADER_TYPE_FREQ,
 		.flags		= IW_DESCR_FLAG_EVENT,
 	},
-	[SIOCGIWFREQ	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCGIWFREQ)] = {
 		.header_type	= IW_HEADER_TYPE_FREQ,
 		.flags		= IW_DESCR_FLAG_DUMP,
 	},
-	[SIOCSIWMODE	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCSIWMODE)] = {
 		.header_type	= IW_HEADER_TYPE_UINT,
 		.flags		= IW_DESCR_FLAG_EVENT,
 	},
-	[SIOCGIWMODE	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCGIWMODE)] = {
 		.header_type	= IW_HEADER_TYPE_UINT,
 		.flags		= IW_DESCR_FLAG_DUMP,
 	},
-	[SIOCSIWSENS	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCSIWSENS)] = {
 		.header_type	= IW_HEADER_TYPE_PARAM,
 	},
-	[SIOCGIWSENS	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCGIWSENS)] = {
 		.header_type	= IW_HEADER_TYPE_PARAM,
 	},
-	[SIOCSIWRANGE	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCSIWRANGE)] = {
 		.header_type	= IW_HEADER_TYPE_NULL,
 	},
-	[SIOCGIWRANGE	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCGIWRANGE)] = {
 		.header_type	= IW_HEADER_TYPE_POINT,
 		.token_size	= 1,
 		.max_tokens	= sizeof(struct iw_range),
 		.flags		= IW_DESCR_FLAG_DUMP,
 	},
-	[SIOCSIWPRIV	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCSIWPRIV)] = {
 		.header_type	= IW_HEADER_TYPE_NULL,
 	},
-	[SIOCGIWPRIV	- SIOCIWFIRST] = { /* (handled directly by us) */
+	[IW_IOCTL_IDX(SIOCGIWPRIV)] = { /* (handled directly by us) */
 		.header_type	= IW_HEADER_TYPE_POINT,
 		.token_size	= sizeof(struct iw_priv_args),
 		.max_tokens	= 16,
 		.flags		= IW_DESCR_FLAG_NOMAX,
 	},
-	[SIOCSIWSTATS	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCSIWSTATS)] = {
 		.header_type	= IW_HEADER_TYPE_NULL,
 	},
-	[SIOCGIWSTATS	- SIOCIWFIRST] = { /* (handled directly by us) */
+	[IW_IOCTL_IDX(SIOCGIWSTATS)] = { /* (handled directly by us) */
 		.header_type	= IW_HEADER_TYPE_POINT,
 		.token_size	= 1,
 		.max_tokens	= sizeof(struct iw_statistics),
 		.flags		= IW_DESCR_FLAG_DUMP,
 	},
-	[SIOCSIWSPY	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCSIWSPY)] = {
 		.header_type	= IW_HEADER_TYPE_POINT,
 		.token_size	= sizeof(struct sockaddr),
 		.max_tokens	= IW_MAX_SPY,
 	},
-	[SIOCGIWSPY	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCGIWSPY)] = {
 		.header_type	= IW_HEADER_TYPE_POINT,
 		.token_size	= sizeof(struct sockaddr) +
 				  sizeof(struct iw_quality),
 		.max_tokens	= IW_MAX_SPY,
 	},
-	[SIOCSIWTHRSPY	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCSIWTHRSPY)] = {
 		.header_type	= IW_HEADER_TYPE_POINT,
 		.token_size	= sizeof(struct iw_thrspy),
 		.min_tokens	= 1,
 		.max_tokens	= 1,
 	},
-	[SIOCGIWTHRSPY	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCGIWTHRSPY)] = {
 		.header_type	= IW_HEADER_TYPE_POINT,
 		.token_size	= sizeof(struct iw_thrspy),
 		.min_tokens	= 1,
 		.max_tokens	= 1,
 	},
-	[SIOCSIWAP	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCSIWAP)] = {
 		.header_type	= IW_HEADER_TYPE_ADDR,
 	},
-	[SIOCGIWAP	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCGIWAP)] = {
 		.header_type	= IW_HEADER_TYPE_ADDR,
 		.flags		= IW_DESCR_FLAG_DUMP,
 	},
-	[SIOCSIWMLME	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCSIWMLME)] = {
 		.header_type	= IW_HEADER_TYPE_POINT,
 		.token_size	= 1,
 		.min_tokens	= sizeof(struct iw_mlme),
 		.max_tokens	= sizeof(struct iw_mlme),
 	},
-	[SIOCGIWAPLIST	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCGIWAPLIST)] = {
 		.header_type	= IW_HEADER_TYPE_POINT,
 		.token_size	= sizeof(struct sockaddr) +
 				  sizeof(struct iw_quality),
 		.max_tokens	= IW_MAX_AP,
 		.flags		= IW_DESCR_FLAG_NOMAX,
 	},
-	[SIOCSIWSCAN	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCSIWSCAN)] = {
 		.header_type	= IW_HEADER_TYPE_POINT,
 		.token_size	= 1,
 		.min_tokens	= 0,
 		.max_tokens	= sizeof(struct iw_scan_req),
 	},
-	[SIOCGIWSCAN	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCGIWSCAN)] = {
 		.header_type	= IW_HEADER_TYPE_POINT,
 		.token_size	= 1,
 		.max_tokens	= IW_SCAN_MAX_DATA,
 		.flags		= IW_DESCR_FLAG_NOMAX,
 	},
-	[SIOCSIWESSID	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCSIWESSID)] = {
 		.header_type	= IW_HEADER_TYPE_POINT,
 		.token_size	= 1,
 		.max_tokens	= IW_ESSID_MAX_SIZE,
 		.flags		= IW_DESCR_FLAG_EVENT,
 	},
-	[SIOCGIWESSID	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCGIWESSID)] = {
 		.header_type	= IW_HEADER_TYPE_POINT,
 		.token_size	= 1,
 		.max_tokens	= IW_ESSID_MAX_SIZE,
 		.flags		= IW_DESCR_FLAG_DUMP,
 	},
-	[SIOCSIWNICKN	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCSIWNICKN)] = {
 		.header_type	= IW_HEADER_TYPE_POINT,
 		.token_size	= 1,
 		.max_tokens	= IW_ESSID_MAX_SIZE,
 	},
-	[SIOCGIWNICKN	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCGIWNICKN)] = {
 		.header_type	= IW_HEADER_TYPE_POINT,
 		.token_size	= 1,
 		.max_tokens	= IW_ESSID_MAX_SIZE,
 	},
-	[SIOCSIWRATE	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCSIWRATE)] = {
 		.header_type	= IW_HEADER_TYPE_PARAM,
 	},
-	[SIOCGIWRATE	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCGIWRATE)] = {
 		.header_type	= IW_HEADER_TYPE_PARAM,
 	},
-	[SIOCSIWRTS	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCSIWRTS)] = {
 		.header_type	= IW_HEADER_TYPE_PARAM,
 	},
-	[SIOCGIWRTS	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCGIWRTS)] = {
 		.header_type	= IW_HEADER_TYPE_PARAM,
 	},
-	[SIOCSIWFRAG	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCSIWFRAG)] = {
 		.header_type	= IW_HEADER_TYPE_PARAM,
 	},
-	[SIOCGIWFRAG	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCGIWFRAG)] = {
 		.header_type	= IW_HEADER_TYPE_PARAM,
 	},
-	[SIOCSIWTXPOW	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCSIWTXPOW)] = {
 		.header_type	= IW_HEADER_TYPE_PARAM,
 	},
-	[SIOCGIWTXPOW	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCGIWTXPOW)] = {
 		.header_type	= IW_HEADER_TYPE_PARAM,
 	},
-	[SIOCSIWRETRY	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCSIWRETRY)] = {
 		.header_type	= IW_HEADER_TYPE_PARAM,
 	},
-	[SIOCGIWRETRY	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCGIWRETRY)] = {
 		.header_type	= IW_HEADER_TYPE_PARAM,
 	},
-	[SIOCSIWENCODE	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCSIWENCODE)] = {
 		.header_type	= IW_HEADER_TYPE_POINT,
 		.token_size	= 1,
 		.max_tokens	= IW_ENCODING_TOKEN_MAX,
 		.flags		= IW_DESCR_FLAG_EVENT | IW_DESCR_FLAG_RESTRICT,
 	},
-	[SIOCGIWENCODE	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCGIWENCODE)] = {
 		.header_type	= IW_HEADER_TYPE_POINT,
 		.token_size	= 1,
 		.max_tokens	= IW_ENCODING_TOKEN_MAX,
 		.flags		= IW_DESCR_FLAG_DUMP | IW_DESCR_FLAG_RESTRICT,
 	},
-	[SIOCSIWPOWER	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCSIWPOWER)] = {
 		.header_type	= IW_HEADER_TYPE_PARAM,
 	},
-	[SIOCGIWPOWER	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCGIWPOWER)] = {
 		.header_type	= IW_HEADER_TYPE_PARAM,
 	},
-	[SIOCSIWGENIE	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCSIWGENIE)] = {
 		.header_type	= IW_HEADER_TYPE_POINT,
 		.token_size	= 1,
 		.max_tokens	= IW_GENERIC_IE_MAX,
 	},
-	[SIOCGIWGENIE	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCGIWGENIE)] = {
 		.header_type	= IW_HEADER_TYPE_POINT,
 		.token_size	= 1,
 		.max_tokens	= IW_GENERIC_IE_MAX,
 	},
-	[SIOCSIWAUTH	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCSIWAUTH)] = {
 		.header_type	= IW_HEADER_TYPE_PARAM,
 	},
-	[SIOCGIWAUTH	- SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCGIWAUTH)] = {
 		.header_type	= IW_HEADER_TYPE_PARAM,
 	},
-	[SIOCSIWENCODEEXT - SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCSIWENCODEEXT)] = {
 		.header_type	= IW_HEADER_TYPE_POINT,
 		.token_size	= 1,
 		.min_tokens	= sizeof(struct iw_encode_ext),
 		.max_tokens	= sizeof(struct iw_encode_ext) +
 				  IW_ENCODING_TOKEN_MAX,
 	},
-	[SIOCGIWENCODEEXT - SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCGIWENCODEEXT)] = {
 		.header_type	= IW_HEADER_TYPE_POINT,
 		.token_size	= 1,
 		.min_tokens	= sizeof(struct iw_encode_ext),
 		.max_tokens	= sizeof(struct iw_encode_ext) +
 				  IW_ENCODING_TOKEN_MAX,
 	},
-	[SIOCSIWPMKSA - SIOCIWFIRST] = {
+	[IW_IOCTL_IDX(SIOCSIWPMKSA)] = {
 		.header_type	= IW_HEADER_TYPE_POINT,
 		.token_size	= 1,
 		.min_tokens	= sizeof(struct iw_pmksa),
@@ -449,7 +449,7 @@ void wireless_send_event(struct net_device *	dev,
 
 	/* Get the description of the Event */
 	if (cmd <= SIOCIWLAST) {
-		cmd_index = cmd - SIOCIWFIRST;
+		cmd_index = IW_IOCTL_IDX(cmd);
 		if (cmd_index < standard_ioctl_num)
 			descr = &(standard_ioctl[cmd_index]);
 	} else {
@@ -662,7 +662,7 @@ static iw_handler get_handler(struct net_device *dev, unsigned int cmd)
 		return NULL;
 
 	/* Try as a standard command */
-	index = cmd - SIOCIWFIRST;
+	index = IW_IOCTL_IDX(cmd);
 	if (index < handlers->num_standard)
 		return handlers->standard[index];
 
@@ -954,9 +954,9 @@ static int ioctl_standard_call(struct net_device *	dev,
 	int					ret = -EINVAL;
 
 	/* Get the description of the IOCTL */
-	if ((cmd - SIOCIWFIRST) >= standard_ioctl_num)
+	if (IW_IOCTL_IDX(cmd) >= standard_ioctl_num)
 		return -EOPNOTSUPP;
-	descr = &(standard_ioctl[cmd - SIOCIWFIRST]);
+	descr = &(standard_ioctl[IW_IOCTL_IDX(cmd)]);
 
 	/* Check if we have a pointer to user space data or not */
 	if (descr->header_type != IW_HEADER_TYPE_POINT) {
@@ -1012,7 +1012,7 @@ static int compat_standard_call(struct net_device	*dev,
 	struct iw_point iwp;
 	int err;
 
-	descr = standard_ioctl + (cmd - SIOCIWFIRST);
+	descr = standard_ioctl + IW_IOCTL_IDX(cmd);
 
 	if (descr->header_type != IW_HEADER_TYPE_POINT)
 		return ioctl_standard_call(dev, iwr, cmd, info, handler);
-- 
1.7.0.14.g7e948

