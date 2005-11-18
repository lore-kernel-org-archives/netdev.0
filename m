From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] drivers/net/wireless/orinoco.h: "extern inline" -> "static inline"
Date: Fri, 18 Nov 2005 04:33:29 +0100
Message-ID: <20051118033329.GU11494@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: orinoco-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932273AbVKRDdo@vger.kernel.org>
To: proski@gnu.org, hermes@gibson.dropbear.id.au
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"extern inline" doesn't make much sense.


Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 drivers/net/wireless/orinoco.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- linux-2.6.15-rc1-mm1-full/drivers/net/wireless/orinoco.h.old	2005-11-18 02:38:43.000000000 +0100
+++ linux-2.6.15-rc1-mm1-full/drivers/net/wireless/orinoco.h	2005-11-18 02:38:47.000000000 +0100
@@ -155,7 +155,7 @@
  * SPARC, due to its weird semantics for save/restore flags. extern
  * inline should prevent the kernel from linking or module from
  * loading if they are not inlined. */
-extern inline int orinoco_lock(struct orinoco_private *priv,
+static inline int orinoco_lock(struct orinoco_private *priv,
 			       unsigned long *flags)
 {
 	spin_lock_irqsave(&priv->lock, *flags);
@@ -168,7 +168,7 @@
 	return 0;
 }
 
-extern inline void orinoco_unlock(struct orinoco_private *priv,
+static inline void orinoco_unlock(struct orinoco_private *priv,
 				  unsigned long *flags)
 {
 	spin_unlock_irqrestore(&priv->lock, *flags);
