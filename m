From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.10-rc2-netdev1 2/4] r8169: C made easy
Date: Tue, 16 Nov 2004 23:33:32 +0100
Message-ID: <20041116223332.GA16781@electric-eye.fr.zoreil.com>
References: <20041116223040.GA16715@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20041116223040.GA16715@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Back to C101 and code which gives the expected result.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/r8169.c~r8169-255 drivers/net/r8169.c
--- linux-2.6.10-rc2-mm1.orig/drivers/net/r8169.c~r8169-255	2004-11-16 20:23:48.000000000 +0100
+++ linux-2.6.10-rc2-mm1/drivers/net/r8169.c	2004-11-16 22:26:14.000000000 +0100
@@ -1978,7 +1978,7 @@ static void rtl8169_pcierr_interrupt(str
 		PCI_STATUS_REC_TARGET_ABORT | PCI_STATUS_SIG_TARGET_ABORT));
 
 	/* The infamous DAC f*ckup only happens at boot time */
-	if ((tp->cp_cmd & PCIDAC) && (tp->dirty_rx == tp->cur_rx == 0)) {
+	if ((tp->cp_cmd & PCIDAC) && !tp->dirty_rx && !tp->cur_rx) {
 		printk(KERN_INFO PFX "%s: disabling PCI DAC.\n", dev->name);
 		tp->cp_cmd &= ~PCIDAC;
 		RTL_W16(CPlusCmd, tp->cp_cmd);

_
