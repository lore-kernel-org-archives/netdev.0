From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] MAINTAINERS: remove Adam Fritzler, update his email
	address in other sources
Date: Mon, 17 Dec 2007 20:48:03 -0800
Message-ID: <1197953283.4891.24.camel@localhost>
References: <1197951126.4891.13.camel@localhost>
	 <20071217202800.1c898441.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	Adam Fritzler <mid@zigamorph.net>,
	"James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>,
	Jeff Garzik <jgarzik@pobox.com>,
	Mike Phillips <mikep@linuxtr.net>,
	Philip Blundell <philb@gnu.org>, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org, Adrian Bunk <bunk@stusta.de>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:3841 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752107AbXLREsP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 23:48:15 -0500
In-Reply-To: <20071217202800.1c898441.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2007-12-17 at 20:28 -0800, Andrew Morton wrote:
> Please: just replace all instances with plain old "Adam Fritzler" and then
> ensure that the lookup key "Adam Fritzler" has an accurate (and
> non-duplicated anywhere else!) entry in MAINTAINERS or CREDITS or whatever.

Sure.  See new patch below

> btw, I cheerfully skipped all your spelling-fixes patches.

No worries.  I was just avoiding doing useful stuff.

> Some will have
> stuck via subsystem maintainers but I have a secret "no spelling fixes
> unless they're end-user-visible" policy.

I think there were 15-20 printks in that lot.
Do you want them separately?

> I'd suggest that you find out if Adrian is still running the trivial tree
> and if so, patchbomb him.

OK.  Adrian?  Do you want the spelling fixes?

Back to Adam Fritzler...

Signed-off-by: Joe Perches <joe@perches.com>
---
 CREDITS                          |    3 +++
 MAINTAINERS                      |    7 -------
 drivers/net/eexpress.c           |    2 +-
 drivers/net/tokenring/abyss.c    |    2 +-
 drivers/net/tokenring/abyss.h    |    2 +-
 drivers/net/tokenring/madgemc.c  |    2 +-
 drivers/net/tokenring/madgemc.h  |    2 +-
 drivers/net/tokenring/proteon.c  |    2 +-
 drivers/net/tokenring/skisa.c    |    2 +-
 drivers/net/tokenring/tms380tr.c |    2 +-
 drivers/net/tokenring/tms380tr.h |    2 +-
 drivers/net/tokenring/tmspci.c   |    2 +-
 drivers/scsi/aha1542.c           |    2 +-
 13 files changed, 14 insertions(+), 18 deletions(-)

diff --git a/CREDITS b/CREDITS
index ee909f2..449ec7f 100644
--- a/CREDITS
+++ b/CREDITS
@@ -1124,6 +1124,9 @@ S: 1150 Ringwood Court
 S: San Jose, California 95131
 S: USA
 
+N: Adam Fritzler
+E: mid@zigamorph.net
+
 N: Fernando Fuganti
 E: fuganti@conectiva.com.br
 E: fuganti@netbank.com.br
diff --git a/MAINTAINERS b/MAINTAINERS
index 9507b42..690f172 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3758,13 +3758,6 @@ W:	http://www.kernel.org/pub/linux/kernel/people/bunk/trivial/
 T:	git kernel.org:/pub/scm/linux/kernel/git/bunk/trivial.git
 S:	Maintained
 
-TMS380 TOKEN-RING NETWORK DRIVER
-P:	Adam Fritzler
-M:	mid@auk.cx
-L:	linux-tr@linuxtr.net
-W:	http://www.auk.cx/tms380tr/
-S:	Maintained
-
 TULIP NETWORK DRIVER
 L:	tulip-users@lists.sourceforge.net
 W:	http://sourceforge.net/projects/tulip/
diff --git a/drivers/net/eexpress.c b/drivers/net/eexpress.c
index 70509ed..283fc8f 100644
--- a/drivers/net/eexpress.c
+++ b/drivers/net/eexpress.c
@@ -9,7 +9,7 @@
  * Many modifications, and currently maintained, by
  *  Philip Blundell <philb@gnu.org>
  * Added the Compaq LTE  Alan Cox <alan@redhat.com>
- * Added MCA support Adam Fritzler <mid@auk.cx>
+ * Added MCA support Adam Fritzler
  *
  * Note - this driver is experimental still - it has problems on faster
  * machines. Someone needs to sit down and go through it line by line with
diff --git a/drivers/net/tokenring/abyss.c b/drivers/net/tokenring/abyss.c
index 124cfd4..7a7de04 100644
--- a/drivers/net/tokenring/abyss.c
+++ b/drivers/net/tokenring/abyss.c
@@ -10,7 +10,7 @@
  *      - Madge Smart 16/4 PCI Mk2
  *
  *  Maintainer(s):
- *    AF	Adam Fritzler		mid@auk.cx
+ *    AF	Adam Fritzler
  *
  *  Modification History:
  *	30-Dec-99	AF	Split off from the tms380tr driver.
diff --git a/drivers/net/tokenring/abyss.h b/drivers/net/tokenring/abyss.h
index 0ee6e4f..b0a473b 100644
--- a/drivers/net/tokenring/abyss.h
+++ b/drivers/net/tokenring/abyss.h
@@ -2,7 +2,7 @@
  * abyss.h: Header for the abyss tms380tr module
  *
  * Authors:
- * - Adam Fritzler <mid@auk.cx>
+ * - Adam Fritzler
  */
 
 #ifndef __LINUX_MADGETR_H
diff --git a/drivers/net/tokenring/madgemc.c b/drivers/net/tokenring/madgemc.c
index 5a41513..c9c5a2b 100644
--- a/drivers/net/tokenring/madgemc.c
+++ b/drivers/net/tokenring/madgemc.c
@@ -11,7 +11,7 @@
  *	- Madge Smart 16/4 Ringnode MC32 (??)
  *
  *  Maintainer(s):
- *    AF	Adam Fritzler		mid@auk.cx
+ *    AF	Adam Fritzler
  *
  *  Modification History:
  *	16-Jan-00	AF	Created
diff --git a/drivers/net/tokenring/madgemc.h b/drivers/net/tokenring/madgemc.h
index 2dd8222..fe88e27 100644
--- a/drivers/net/tokenring/madgemc.h
+++ b/drivers/net/tokenring/madgemc.h
@@ -2,7 +2,7 @@
  * madgemc.h: Header for the madgemc tms380tr module
  *
  * Authors:
- * - Adam Fritzler <mid@auk.cx>
+ * - Adam Fritzler
  */
 
 #ifndef __LINUX_MADGEMC_H
diff --git a/drivers/net/tokenring/proteon.c b/drivers/net/tokenring/proteon.c
index ca6b659..00ea945 100644
--- a/drivers/net/tokenring/proteon.c
+++ b/drivers/net/tokenring/proteon.c
@@ -12,7 +12,7 @@
  *	- Proteon 1392, 1392+
  *
  *  Maintainer(s):
- *    AF        Adam Fritzler           mid@auk.cx
+ *    AF        Adam Fritzler
  *    JF	Jochen Friedrich	jochen@scram.de
  *
  *  Modification History:
diff --git a/drivers/net/tokenring/skisa.c b/drivers/net/tokenring/skisa.c
index 32e8d5a..41b6999 100644
--- a/drivers/net/tokenring/skisa.c
+++ b/drivers/net/tokenring/skisa.c
@@ -13,7 +13,7 @@
  *	- SysKonnect TR4/16(+) ISA	(SK-4190)
  *
  *  Maintainer(s):
- *    AF        Adam Fritzler           mid@auk.cx
+ *    AF        Adam Fritzler
  *    JF	Jochen Friedrich	jochen@scram.de
  *
  *  Modification History:
diff --git a/drivers/net/tokenring/tms380tr.c b/drivers/net/tokenring/tms380tr.c
index d5fa36d..d07c452 100644
--- a/drivers/net/tokenring/tms380tr.c
+++ b/drivers/net/tokenring/tms380tr.c
@@ -30,7 +30,7 @@
  *  Maintainer(s):
  *    JS	Jay Schulist		jschlst@samba.org
  *    CG	Christoph Goos		cgoos@syskonnect.de
- *    AF	Adam Fritzler		mid@auk.cx
+ *    AF	Adam Fritzler
  *    MLP       Mike Phillips           phillim@amtrak.com
  *    JF	Jochen Friedrich	jochen@scram.de
  *     
diff --git a/drivers/net/tokenring/tms380tr.h b/drivers/net/tokenring/tms380tr.h
index 7daf74e..7af76d7 100644
--- a/drivers/net/tokenring/tms380tr.h
+++ b/drivers/net/tokenring/tms380tr.h
@@ -3,7 +3,7 @@
  *
  * Authors:
  * - Christoph Goos <cgoos@syskonnect.de>
- * - Adam Fritzler <mid@auk.cx>
+ * - Adam Fritzler
  */
 
 #ifndef __LINUX_TMS380TR_H
diff --git a/drivers/net/tokenring/tmspci.c b/drivers/net/tokenring/tmspci.c
index 1c18f78..5f0ee88 100644
--- a/drivers/net/tokenring/tmspci.c
+++ b/drivers/net/tokenring/tmspci.c
@@ -14,7 +14,7 @@
  *      - 3Com 3C339 Token Link Velocity
  *
  *  Maintainer(s):
- *    AF	Adam Fritzler		mid@auk.cx
+ *    AF	Adam Fritzler
  *
  *  Modification History:
  *	30-Dec-99	AF	Split off from the tms380tr driver.
diff --git a/drivers/scsi/aha1542.c b/drivers/scsi/aha1542.c
index bbcc2c5..db202ea 100644
--- a/drivers/scsi/aha1542.c
+++ b/drivers/scsi/aha1542.c
@@ -21,7 +21,7 @@
  *  Modified by Chris Faulhaber <jedgar@fxp.org>
  *        Added module command-line options
  *        19-Jul-99
- *  Modified by Adam Fritzler <mid@auk.cx>
+ *  Modified by Adam Fritzler
  *        Added proper detection of the AHA-1640 (MCA version of AHA-1540)
  */
 



