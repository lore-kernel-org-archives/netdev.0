From: maximilian attems <janitor@sternwelten.at>
Subject: [patch 4/6] char/shwdt remove duplicate msecs_to_jiffies()
Date: Sun, 31 Oct 2004 15:45:03 +0100
Message-ID: <20041031144503.GE28667@stro.at>
References: <20040923221303.GB13244@us.ibm.com> <20040923221303.GB13244@us.ibm.com> <5.1.0.14.2.20040924074745.00b1cd40@pop.t-online.de> <415CD9D9.2000607@pobox.com> <20041030222228.GB1456@stro.at> <41841886.2080609@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Margit Schubert-While <margitsw@t-online.de>,
        Nishanth Aravamudan <nacc@us.ibm.com>, hvr@gnu.org,
        mcgrof@studorgs.rutgers.edu, kernel-janitors@lists.osdl.org,
        netdev@oss.sgi.com, Domen Puncer <domen@coderock.org>,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <41841886.2080609@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



remove duplicate msecs_to_jiffies() definition.
add include <delay.h>.

Signed-off-by: Maximilian Attems <janitor@sternwelten.at>


---

 linux-2.4.28-rc1-max/drivers/char/shwdt.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/char/shwdt.c~remove-msecs_to_jiffies-drivers_char_shwdt drivers/char/shwdt.c
--- linux-2.4.28-rc1/drivers/char/shwdt.c~remove-msecs_to_jiffies-drivers_char_shwdt	2004-10-31 13:40:49.000000000 +0100
+++ linux-2.4.28-rc1-max/drivers/char/shwdt.c	2004-10-31 13:42:05.000000000 +0100
@@ -27,6 +27,7 @@
 #include <linux/reboot.h>
 #include <linux/notifier.h>
 #include <linux/ioport.h>
+#include <linux/delay.h>
 
 #include <asm/io.h>
 #include <asm/uaccess.h>
@@ -113,7 +114,6 @@
  */
 static int clock_division_ratio = WTCSR_CKS_4096;
 
-#define msecs_to_jiffies(msecs)	(jiffies + (HZ * msecs + 9999) / 10000)
 #define next_ping_period(cks)	msecs_to_jiffies(cks - 4)
 
 static unsigned long shwdt_is_open;
_
