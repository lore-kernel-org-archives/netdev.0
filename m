From: Pavel Machek <pavel@ucw.cz>
Subject: kill unused define in ipw
Date: Wed, 11 May 2005 23:43:07 +0200
Message-ID: <20050511214307.GA3777@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel list <linux-kernel@vger.kernel.org>, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261282AbVEKWNu@vger.kernel.org>
To: jketreno@linux.intel.com
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

This kills unused KILL_CHECK_THRESHOLD and KERNEL_SYSCALLS. They
should not be needed any more. Please apply,

[What is the merge status? Version 1.1 seems quite okay, but it could
use some "#ifdef 2.6.10" removal". Can I help?]
								Pavel
PS: Please Cc me, I'm not on netdev.

Signed-off-by: Pavel Machek <pavel@suse.cz>

--- /data/l/clean-mm/drivers/net/wireless/ipw2100.c	2005-05-11 22:00:02.000000000 +0200
+++ linux-mm/drivers/net/wireless/ipw2100.c	2005-05-11 23:37:25.000000000 +0200
@@ -150,7 +150,6 @@
 #include <linux/skbuff.h>
 #include <asm/uaccess.h>
 #include <asm/io.h>
-#define __KERNEL_SYSCALLS__
 #include <linux/fs.h>
 #include <linux/mm.h>
 #include <linux/slab.h>
@@ -1117,7 +1116,6 @@
 {
 #define MAX_RF_KILL_CHECKS 5
 #define RF_KILL_CHECK_DELAY 40
-#define RF_KILL_CHECK_THRESHOLD 3
 
 	unsigned short value = 0;
 	u32 reg = 0;

-- 
Boycott Kodak -- for their patent abuse against Java.
