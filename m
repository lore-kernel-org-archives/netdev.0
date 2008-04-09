From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] e1000e: set CONFIG_E1000E=y in x86 defconfigs
Date: Wed, 09 Apr 2008 13:17:39 -0700
Message-ID: <20080409201739.14581.7454.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, mingo@elte.hu, linux-kernel@vger.kernel.org,
	andi@firstfloor.org, akpm@linux-foundation.org, davem@davemloft.net
To: torvalds@linux-foundation.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

This adds to the already default CONFIG_E1000=y in these files.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 arch/x86/configs/i386_defconfig   |    1 +
 arch/x86/configs/x86_64_defconfig |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/arch/x86/configs/i386_defconfig b/arch/x86/configs/i386_defconfig
index 3df340b..35f6308 100644
--- a/arch/x86/configs/i386_defconfig
+++ b/arch/x86/configs/i386_defconfig
@@ -814,6 +814,7 @@ CONFIG_NETDEV_1000=y
 CONFIG_E1000=y
 # CONFIG_E1000_NAPI is not set
 # CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
+CONFIG_E1000E=y
 # CONFIG_NS83820 is not set
 # CONFIG_HAMACHI is not set
 # CONFIG_YELLOWFIN is not set
diff --git a/arch/x86/configs/x86_64_defconfig b/arch/x86/configs/x86_64_defconfig
index eef98cb..2d078d7 100644
--- a/arch/x86/configs/x86_64_defconfig
+++ b/arch/x86/configs/x86_64_defconfig
@@ -740,6 +740,7 @@ CONFIG_NETDEV_1000=y
 CONFIG_E1000=y
 # CONFIG_E1000_NAPI is not set
 # CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
+CONFIG_E1000E=y
 # CONFIG_NS83820 is not set
 # CONFIG_HAMACHI is not set
 # CONFIG_YELLOWFIN is not set


-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
