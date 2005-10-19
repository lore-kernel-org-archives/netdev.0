From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.14-rc3] 8139too: fix resume for Realtek 8100B/8139D
Date: Tue, 18 Oct 2005 21:31:00 -0400
Message-ID: <10182005213100.12557@bilbo.tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932463AbVJSBiH@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add "HasHltClk" flag for RTL-8100B/8139D hardware in order to fix
problems resuming from suspend-to-RAM.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 drivers/net/8139too.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -552,7 +552,8 @@ const static struct {
 
 	{ "RTL-8100B/8139D",
 	  HW_REVID(1, 1, 1, 0, 1, 0, 1),
-	  HasLWake,
+	  HasHltClk /* XXX undocumented? */
+	| HasLWake,
 	},
 
 	{ "RTL-8101",
