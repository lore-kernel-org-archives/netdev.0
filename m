From: Danny Kukawka <danny.kukawka-2YacvwyR+KOzQB+pC5nmwQ@public.gmane.org>
Subject: [PATCH 11/16] ath5k: make
	ath5k_modparam_no_hw_rfkill_switch real
Date: Mon, 30 Jan 2012 20:40:53 +0100
Message-ID: <1327952458-7424-12-git-send-email-danny.kukawka@bisect.de>
References: <1327952458-7424-1-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org
Return-path: <ath5k-devel-bounces-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org>
In-Reply-To: <1327952458-7424-1-git-send-email-danny.kukawka-2YacvwyR+KOzQB+pC5nmwQ@public.gmane.org>
List-Unsubscribe: <https://lists.ath5k.org/mailman/listinfo/ath5k-devel>,
	<mailto:ath5k-devel-request-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ath5k.org/pipermail/ath5k-devel>
List-Post: <mailto:ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org>
List-Help: <mailto:ath5k-devel-request-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ath5k.org/mailman/listinfo/ath5k-devel>,
	<mailto:ath5k-devel-request-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org?subject=subscribe>
Sender: ath5k-devel-bounces-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org
Errors-To: ath5k-devel-bounces-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Make ath5k_modparam_no_hw_rfkill_switch real bool to fix:
'warning: return from incompatible pointer type' compiler warning.

Signed-off-by: Danny Kukawka <danny.kukawka-2YacvwyR+KOzQB+pC5nmwQ@public.gmane.org>
---
 drivers/net/wireless/ath/ath5k/base.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/ath/ath5k/base.c b/drivers/net/wireless/ath/ath5k/base.c
index d366dad..ad2f115 100644
--- a/drivers/net/wireless/ath/ath5k/base.c
+++ b/drivers/net/wireless/ath/ath5k/base.c
@@ -80,7 +80,7 @@ static bool modparam_fastchanswitch;
 module_param_named(fastchanswitch, modparam_fastchanswitch, bool, S_IRUGO);
 MODULE_PARM_DESC(fastchanswitch, "Enable fast channel switching for AR2413/AR5413 radios.");
 
-static int ath5k_modparam_no_hw_rfkill_switch;
+static bool ath5k_modparam_no_hw_rfkill_switch;
 module_param_named(no_hw_rfkill_switch, ath5k_modparam_no_hw_rfkill_switch,
 								bool, S_IRUGO);
 MODULE_PARM_DESC(no_hw_rfkill_switch, "Ignore the GPIO RFKill switch state");
-- 
1.7.7.3
