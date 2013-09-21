From: Joe Perches <joe@perches.com>
Subject: [PATCH 09/12] iw_handler.h: Remove extern from function prototypes
Date: Sat, 21 Sep 2013 10:22:49 -0700
Message-ID: <ed8fa3f192a3dbc7305f97c2ac0a0a0f247dd1b3.1379783996.git.joe@perches.com>
References: <005f102eb1322058f9e797a7268ae8be01ecfaae.1379783995.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <005f102eb1322058f9e797a7268ae8be01ecfaae.1379783995.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/iw_handler.h | 38 +++++++++++++-------------------------
 1 file changed, 13 insertions(+), 25 deletions(-)

diff --git a/include/net/iw_handler.h b/include/net/iw_handler.h
index 5d5a6a4..a830b01 100644
--- a/include/net/iw_handler.h
+++ b/include/net/iw_handler.h
@@ -432,44 +432,32 @@ struct iw_public_data {
 /* First : function strictly used inside the kernel */
 
 /* Handle /proc/net/wireless, called in net/code/dev.c */
-extern int dev_get_wireless_info(char * buffer, char **start, off_t offset,
-				 int length);
+int dev_get_wireless_info(char *buffer, char **start, off_t offset, int length);
 
 /* Second : functions that may be called by driver modules */
 
 /* Send a single event to user space */
-extern void wireless_send_event(struct net_device *	dev,
-				unsigned int		cmd,
-				union iwreq_data *	wrqu,
-				const char *		extra);
+void wireless_send_event(struct net_device *dev, unsigned int cmd,
+			 union iwreq_data *wrqu, const char *extra);
 
 /* We may need a function to send a stream of events to user space.
  * More on that later... */
 
 /* Standard handler for SIOCSIWSPY */
-extern int iw_handler_set_spy(struct net_device *	dev,
-			      struct iw_request_info *	info,
-			      union iwreq_data *	wrqu,
-			      char *			extra);
+int iw_handler_set_spy(struct net_device *dev, struct iw_request_info *info,
+		       union iwreq_data *wrqu, char *extra);
 /* Standard handler for SIOCGIWSPY */
-extern int iw_handler_get_spy(struct net_device *	dev,
-			      struct iw_request_info *	info,
-			      union iwreq_data *	wrqu,
-			      char *			extra);
+int iw_handler_get_spy(struct net_device *dev, struct iw_request_info *info,
+		       union iwreq_data *wrqu, char *extra);
 /* Standard handler for SIOCSIWTHRSPY */
-extern int iw_handler_set_thrspy(struct net_device *	dev,
-				 struct iw_request_info *info,
-				 union iwreq_data *	wrqu,
-				 char *			extra);
+int iw_handler_set_thrspy(struct net_device *dev, struct iw_request_info *info,
+			  union iwreq_data *wrqu, char *extra);
 /* Standard handler for SIOCGIWTHRSPY */
-extern int iw_handler_get_thrspy(struct net_device *	dev,
-				 struct iw_request_info *info,
-				 union iwreq_data *	wrqu,
-				 char *			extra);
+int iw_handler_get_thrspy(struct net_device *dev, struct iw_request_info *info,
+			  union iwreq_data *wrqu, char *extra);
 /* Driver call to update spy records */
-extern void wireless_spy_update(struct net_device *	dev,
-				unsigned char *		address,
-				struct iw_quality *	wstats);
+void wireless_spy_update(struct net_device *dev, unsigned char *address,
+			 struct iw_quality *wstats);
 
 /************************* INLINE FUNTIONS *************************/
 /*
-- 
1.8.1.2.459.gbcd45b4.dirty
