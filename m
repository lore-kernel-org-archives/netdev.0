From: Joe Perches <joe@perches.com>
Subject: [PATCH v2 6/7] orinoco/wext.c: Remove local #define STD_IW_HANDLER
Date: Wed, 17 Mar 2010 23:21:39 -0700
Message-ID: <02e23cb16a0d61f38e4550ae4e1f3eb5f8d4ab9d.1268892664.git.joe@perches.com>
References: <cover.1268892663.git.joe@perches.com>
Cc: Richard Kennedy <richard@rsk.demon.co.uk>,
	Johannes Berg <johannes@sipsolutions.net>,
	Pavel Roskin <proski@gnu.org>,
	David Gibson <hermes@gibson.dropbear.id.au>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org,
	orinoco-users@lists.sourceforge.net,
	orinoco-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1268892663.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It's been copied into wireless.h, so this one isn't necessary

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/orinoco/wext.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/orinoco/wext.c b/drivers/net/wireless/orinoco/wext.c
index 31ca241..069c333 100644
--- a/drivers/net/wireless/orinoco/wext.c
+++ b/drivers/net/wireless/orinoco/wext.c
@@ -1505,8 +1505,6 @@ static const struct iw_priv_args orinoco_privtab[] = {
  * Structures to export the Wireless Handlers
  */
 
-#define STD_IW_HANDLER(id, func) \
-	[IW_IOCTL_IDX(id)] = (iw_handler) func
 static const iw_handler	orinoco_handler[] = {
 	STD_IW_HANDLER(SIOCSIWCOMMIT,	orinoco_ioctl_commit),
 	STD_IW_HANDLER(SIOCGIWNAME,	cfg80211_wext_giwname),
-- 
1.7.0.14.g7e948
