From: Andrea Gelmini <andrea.gelmini@gelma.net>
Subject: [PATCH 185/199] drivers/atm/idt77252_tables.h: Checkpatch cleanup
Date: Sun, 23 May 2010 22:06:01 +0200
Message-ID: <1274645175-27335-2-git-send-email-andrea.gelmini@gelma.net>
References: <1274645175-27335-1-git-send-email-andrea.gelmini@gelma.net>
Cc: Chas Williams <chas@cmf.nrl.navy.mil>,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: andrea.gelmini@gelma.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:28708 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753598Ab0EWUG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 May 2010 16:06:26 -0400
Received: by fg-out-1718.google.com with SMTP id 22so1028570fge.1
        for <netdev@vger.kernel.org>; Sun, 23 May 2010 13:06:25 -0700 (PDT)
In-Reply-To: <1274645175-27335-1-git-send-email-andrea.gelmini@gelma.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

drivers/atm/idt77252_tables.h:7: ERROR: that open brace { should be on the previous line
drivers/atm/idt77252_tables.h:267: ERROR: that open brace { should be on the previous line

Signed-off-by: Andrea Gelmini <andrea.gelmini@gelma.net>
---
 drivers/atm/idt77252_tables.h |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/atm/idt77252_tables.h b/drivers/atm/idt77252_tables.h
index b6c8ee5..2e814cf 100644
--- a/drivers/atm/idt77252_tables.h
+++ b/drivers/atm/idt77252_tables.h
@@ -3,8 +3,7 @@
  * Cell Line Rate: 353207.55 (155520000 bps)
  */
 
-static unsigned int log_to_rate[] =
-{
+static unsigned int log_to_rate[] = {
 /* 000 */ 0x8d022e27, /* cps =     10.02, nrm =  3, interval = 35264.00 */
 /* 001 */ 0x8d362e11, /* cps =     10.42, nrm =  3, interval = 33856.00 */
 /* 002 */ 0x8d6e2bf8, /* cps =     10.86, nrm =  3, interval = 32512.00 */
@@ -263,8 +262,7 @@ static unsigned int log_to_rate[] =
 /* 255 */ 0xc9630020, /* cps = 352768.00, nrm = 32, interval =     1.00 */
 };
 
-static unsigned char rate_to_log[] =
-{
+static unsigned char rate_to_log[] = {
 /*          1.00 =>   0 */ 0x00, /* =>     10.02 */
 /*          1.06 =>   0 */ 0x00, /* =>     10.02 */
 /*          1.12 =>   0 */ 0x00, /* =>     10.02 */
-- 
1.7.1.251.gf80a2

