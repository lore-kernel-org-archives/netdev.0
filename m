From: akpm@osdl.org
Subject: [patch 06/10] r8169: C 101
Date: Tue, 04 Jan 2005 21:59:32 -0800
Message-ID: <200501050559.j055xf614691@mail.osdl.org>
Cc: davem@davemloft.net, netdev@oss.sgi.com, akpm@osdl.org,
        romieu@fr.zoreil.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Francois Romieu <romieu@fr.zoreil.com>

Back to C101 and code which gives the expected result.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/drivers/net/r8169.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/r8169.c~r8169-c-101 drivers/net/r8169.c
--- 25/drivers/net/r8169.c~r8169-c-101	2005-01-04 21:57:36.066651320 -0800
+++ 25-akpm/drivers/net/r8169.c	2005-01-04 21:57:44.966298368 -0800
@@ -1979,7 +1979,7 @@ static void rtl8169_pcierr_interrupt(str
 		PCI_STATUS_REC_TARGET_ABORT | PCI_STATUS_SIG_TARGET_ABORT));
 
 	/* The infamous DAC f*ckup only happens at boot time */
-	if ((tp->cp_cmd & PCIDAC) && (tp->dirty_rx == tp->cur_rx == 0)) {
+	if ((tp->cp_cmd & PCIDAC) && !tp->dirty_rx && !tp->cur_rx) {
 		printk(KERN_INFO PFX "%s: disabling PCI DAC.\n", dev->name);
 		tp->cp_cmd &= ~PCIDAC;
 		RTL_W16(CPlusCmd, tp->cp_cmd);
_
