From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] skfp: remove assignment expression in conditional (sparse)
Date: Sun, 10 Oct 2004 15:44:56 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4169BB68.7030206@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010508060201010001000302"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>, jgarzik <jgarzik@pobox.com>,
        mlindner@syskonnect.de
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010508060201010001000302
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Fix sparse warning:
drivers/net/skfp/hwmtm.c:1904:20: warning: assignment expression in
conditional

-- 
~Randy


--------------010508060201010001000302
Content-Type: text/x-patch;
 name="skfp_expr.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="skfp_expr.patch"


Fix sparse warning:
drivers/net/skfp/hwmtm.c:1904:20: warning: assignment expression in conditional

Signed-off-by: Randy Dunlap <rddunlap@osdl.org>

diffstat:=
 drivers/net/skfp/hwmtm.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -Naurp ./drivers/net/skfp/hwmtm.c~skfp_expr ./drivers/net/skfp/hwmtm.c
--- ./drivers/net/skfp/hwmtm.c~skfp_expr	2004-08-13 22:36:59.000000000 -0700
+++ ./drivers/net/skfp/hwmtm.c	2004-10-10 15:15:21.090772760 -0700
@@ -1901,7 +1901,7 @@ void smt_send_mbuf(struct s_smc *smc, SM
 	}
 
 	if (!smc->hw.mac_ring_is_up || frag_count > queue->tx_free) {
-		if (frame_status &= ~LAN_TX) {
+		if ((frame_status &= ~LAN_TX) != 0) {
 			DB_TX("Ring is down: terminate LAN_TX",0,0,2) ;
 		}
 		else {


--------------010508060201010001000302--
