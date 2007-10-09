From: Magnus Damm <magnus.damm@gmail.com>
Subject: ax88796: add superh to kconfig depencencies
Date: Tue, 09 Oct 2007 21:51:38 +0900
Message-ID: <20071009125138.28915.30999.sendpatchset@clockwork.opensource.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: lethal@linux-sh.org, linuxsh-dev@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <linuxsh-dev-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linuxsh-dev>,
	<mailto:linuxsh-dev-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linuxsh-dev>
List-Post: <mailto:linuxsh-dev@lists.sourceforge.net>
List-Help: <mailto:linuxsh-dev-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linuxsh-dev>,
	<mailto:linuxsh-dev-request@lists.sourceforge.net?subject=subscribe>
Sender: linuxsh-dev-bounces@lists.sourceforge.net
Errors-To: linuxsh-dev-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

ax88796: add superh to kconfig depencencies

This patch adds sh architecture support to the ax88796 kconfig.

Signed-off-by: Magnus Damm <damm@igel.co.jp>
---

 This is a broken out version of the larger patch recently posted to netdev:
 http://www.mail-archive.com/netdev@vger.kernel.org/msg47278.html

 drivers/net/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- 0002/drivers/net/Kconfig
+++ work/drivers/net/Kconfig	2007-10-09 19:37:27.000000000 +0900
@@ -218,7 +218,7 @@ source "drivers/net/arm/Kconfig"
 
 config AX88796
 	tristate "ASIX AX88796 NE2000 clone support"
-	depends on ARM || MIPS
+	depends on ARM || MIPS || SUPERH
 	select CRC32
 	select MII
 	help

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
