From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 2/4] e1000: enable NAPI by default in defconfig
Date: Mon, 19 May 2008 15:45:11 -0700
Message-ID: <20080519224415.7175.12473.stgit@localhost.localdomain>
References: <20080519224303.7175.71980.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080519224303.7175.71980.stgit@localhost.localdomain>
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


It's preferred to run with NAPI enabled, even for e1000. e1000e
runs at all times in NAPI mode so this setting is not used.

In the future we'll make e1000 NAPI-only.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 arch/ia64/configs/generic_defconfig             |    2 +-
 arch/ia64/configs/gensparse_defconfig           |    2 +-
 arch/ia64/configs/tiger_defconfig               |    2 +-
 arch/ia64/configs/zx1_defconfig                 |    2 +-
 arch/mips/configs/mtx1_defconfig                |    2 +-
 arch/parisc/configs/c3000_defconfig             |    2 +-
 arch/powerpc/configs/83xx/mpc832x_rdb_defconfig |    2 +-
 arch/powerpc/configs/g5_defconfig               |    2 +-
 arch/powerpc/configs/iseries_defconfig          |    2 +-
 arch/powerpc/configs/maple_defconfig            |    2 +-
 arch/powerpc/configs/ppc64_defconfig            |    2 +-
 arch/powerpc/configs/prpmc2800_defconfig        |    2 +-
 arch/powerpc/configs/pseries_defconfig          |    2 +-
 arch/ppc/configs/bamboo_defconfig               |    2 +-
 arch/ppc/configs/katana_defconfig               |    2 +-
 arch/sh/configs/r7780mp_defconfig               |    2 +-
 arch/x86/configs/i386_defconfig                 |    2 +-
 arch/x86/configs/x86_64_defconfig               |    2 +-
 18 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/arch/ia64/configs/generic_defconfig b/arch/ia64/configs/generic_defconfig
index 0210545..b1694e2 100644
--- a/arch/ia64/configs/generic_defconfig
+++ b/arch/ia64/configs/generic_defconfig
@@ -592,7 +592,7 @@ CONFIG_NETDEV_1000=y
 # CONFIG_ACENIC is not set
 # CONFIG_DL2K is not set
 CONFIG_E1000=y
-# CONFIG_E1000_NAPI is not set
+CONFIG_E1000_NAPI=y
 # CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_NS83820 is not set
 # CONFIG_HAMACHI is not set
diff --git a/arch/ia64/configs/gensparse_defconfig b/arch/ia64/configs/gensparse_defconfig
index e86fbd3..dc46ad6 100644
--- a/arch/ia64/configs/gensparse_defconfig
+++ b/arch/ia64/configs/gensparse_defconfig
@@ -594,7 +594,7 @@ CONFIG_E100=m
 # CONFIG_ACENIC is not set
 # CONFIG_DL2K is not set
 CONFIG_E1000=y
-# CONFIG_E1000_NAPI is not set
+CONFIG_E1000_NAPI=y
 # CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_NS83820 is not set
 # CONFIG_HAMACHI is not set
diff --git a/arch/ia64/configs/tiger_defconfig b/arch/ia64/configs/tiger_defconfig
index 797acf9..780fb99 100644
--- a/arch/ia64/configs/tiger_defconfig
+++ b/arch/ia64/configs/tiger_defconfig
@@ -574,7 +574,7 @@ CONFIG_NETDEV_1000=y
 # CONFIG_ACENIC is not set
 # CONFIG_DL2K is not set
 CONFIG_E1000=y
-# CONFIG_E1000_NAPI is not set
+CONFIG_E1000_NAPI=y
 # CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_NS83820 is not set
 # CONFIG_HAMACHI is not set
diff --git a/arch/ia64/configs/zx1_defconfig b/arch/ia64/configs/zx1_defconfig
index 0a06b13..4122b76 100644
--- a/arch/ia64/configs/zx1_defconfig
+++ b/arch/ia64/configs/zx1_defconfig
@@ -634,7 +634,7 @@ CONFIG_E100=y
 # CONFIG_ACENIC is not set
 # CONFIG_DL2K is not set
 CONFIG_E1000=y
-# CONFIG_E1000_NAPI is not set
+CONFIG_E1000_NAPI=y
 # CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_NS83820 is not set
 # CONFIG_HAMACHI is not set
diff --git a/arch/mips/configs/mtx1_defconfig b/arch/mips/configs/mtx1_defconfig
index fa3aa39..46c6773 100644
--- a/arch/mips/configs/mtx1_defconfig
+++ b/arch/mips/configs/mtx1_defconfig
@@ -1297,7 +1297,7 @@ CONFIG_ACENIC=m
 # CONFIG_ACENIC_OMIT_TIGON_I is not set
 CONFIG_DL2K=m
 CONFIG_E1000=m
-# CONFIG_E1000_NAPI is not set
+CONFIG_E1000_NAPI=y
 # CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 CONFIG_NS83820=m
 CONFIG_HAMACHI=m
diff --git a/arch/parisc/configs/c3000_defconfig b/arch/parisc/configs/c3000_defconfig
index c6def3c..c89d490 100644
--- a/arch/parisc/configs/c3000_defconfig
+++ b/arch/parisc/configs/c3000_defconfig
@@ -552,7 +552,7 @@ CONFIG_ACENIC=m
 # CONFIG_ACENIC_OMIT_TIGON_I is not set
 # CONFIG_DL2K is not set
 CONFIG_E1000=m
-# CONFIG_E1000_NAPI is not set
+CONFIG_E1000_NAPI=y
 # CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_E1000E is not set
 # CONFIG_NS83820 is not set
diff --git a/arch/powerpc/configs/83xx/mpc832x_rdb_defconfig b/arch/powerpc/configs/83xx/mpc832x_rdb_defconfig
index ac91302..422af21 100644
--- a/arch/powerpc/configs/83xx/mpc832x_rdb_defconfig
+++ b/arch/powerpc/configs/83xx/mpc832x_rdb_defconfig
@@ -513,7 +513,7 @@ CONFIG_NETDEV_1000=y
 # CONFIG_ACENIC is not set
 # CONFIG_DL2K is not set
 CONFIG_E1000=y
-# CONFIG_E1000_NAPI is not set
+CONFIG_E1000_NAPI=y
 # CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_E1000E is not set
 # CONFIG_E1000E_ENABLED is not set
diff --git a/arch/powerpc/configs/g5_defconfig b/arch/powerpc/configs/g5_defconfig
index 88338a9..e422b71 100644
--- a/arch/powerpc/configs/g5_defconfig
+++ b/arch/powerpc/configs/g5_defconfig
@@ -727,7 +727,7 @@ CONFIG_ACENIC=y
 CONFIG_ACENIC_OMIT_TIGON_I=y
 # CONFIG_DL2K is not set
 CONFIG_E1000=y
-# CONFIG_E1000_NAPI is not set
+CONFIG_E1000_NAPI=y
 # CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_E1000E is not set
 # CONFIG_E1000E_ENABLED is not set
diff --git a/arch/powerpc/configs/iseries_defconfig b/arch/powerpc/configs/iseries_defconfig
index b3128fb..54a0f8f 100644
--- a/arch/powerpc/configs/iseries_defconfig
+++ b/arch/powerpc/configs/iseries_defconfig
@@ -654,7 +654,7 @@ CONFIG_ACENIC=m
 # CONFIG_ACENIC_OMIT_TIGON_I is not set
 # CONFIG_DL2K is not set
 CONFIG_E1000=m
-# CONFIG_E1000_NAPI is not set
+CONFIG_E1000_NAPI=y
 # CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_E1000E is not set
 # CONFIG_E1000E_ENABLED is not set
diff --git a/arch/powerpc/configs/maple_defconfig b/arch/powerpc/configs/maple_defconfig
index 7a166a3..1006be8 100644
--- a/arch/powerpc/configs/maple_defconfig
+++ b/arch/powerpc/configs/maple_defconfig
@@ -607,7 +607,7 @@ CONFIG_NETDEV_1000=y
 # CONFIG_ACENIC is not set
 # CONFIG_DL2K is not set
 CONFIG_E1000=y
-# CONFIG_E1000_NAPI is not set
+CONFIG_E1000_NAPI=y
 # CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_E1000E is not set
 # CONFIG_NS83820 is not set
diff --git a/arch/powerpc/configs/ppc64_defconfig b/arch/powerpc/configs/ppc64_defconfig
index 970282b..19520f7 100644
--- a/arch/powerpc/configs/ppc64_defconfig
+++ b/arch/powerpc/configs/ppc64_defconfig
@@ -934,7 +934,7 @@ CONFIG_ACENIC=y
 CONFIG_ACENIC_OMIT_TIGON_I=y
 # CONFIG_DL2K is not set
 CONFIG_E1000=y
-# CONFIG_E1000_NAPI is not set
+CONFIG_E1000_NAPI=y
 # CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_E1000E is not set
 # CONFIG_E1000E_ENABLED is not set
diff --git a/arch/powerpc/configs/prpmc2800_defconfig b/arch/powerpc/configs/prpmc2800_defconfig
index f912168..214a2d9 100644
--- a/arch/powerpc/configs/prpmc2800_defconfig
+++ b/arch/powerpc/configs/prpmc2800_defconfig
@@ -731,7 +731,7 @@ CONFIG_NETDEV_1000=y
 # CONFIG_ACENIC is not set
 # CONFIG_DL2K is not set
 CONFIG_E1000=y
-# CONFIG_E1000_NAPI is not set
+CONFIG_E1000_NAPI=y
 # CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_E1000E is not set
 # CONFIG_E1000E_ENABLED is not set
diff --git a/arch/powerpc/configs/pseries_defconfig b/arch/powerpc/configs/pseries_defconfig
index 3e2593c..d0ac5fb 100644
--- a/arch/powerpc/configs/pseries_defconfig
+++ b/arch/powerpc/configs/pseries_defconfig
@@ -807,7 +807,7 @@ CONFIG_ACENIC=y
 CONFIG_ACENIC_OMIT_TIGON_I=y
 # CONFIG_DL2K is not set
 CONFIG_E1000=y
-# CONFIG_E1000_NAPI is not set
+CONFIG_E1000_NAPI=y
 # CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_E1000E is not set
 # CONFIG_E1000E_ENABLED is not set
diff --git a/arch/ppc/configs/bamboo_defconfig b/arch/ppc/configs/bamboo_defconfig
index 41fd393..cb4998e 100644
--- a/arch/ppc/configs/bamboo_defconfig
+++ b/arch/ppc/configs/bamboo_defconfig
@@ -498,7 +498,7 @@ CONFIG_NATSEMI=y
 # CONFIG_ACENIC is not set
 # CONFIG_DL2K is not set
 CONFIG_E1000=y
-# CONFIG_E1000_NAPI is not set
+CONFIG_E1000_NAPI=y
 # CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_NS83820 is not set
 # CONFIG_HAMACHI is not set
diff --git a/arch/ppc/configs/katana_defconfig b/arch/ppc/configs/katana_defconfig
index 7311fe6..b5329ac 100644
--- a/arch/ppc/configs/katana_defconfig
+++ b/arch/ppc/configs/katana_defconfig
@@ -487,7 +487,7 @@ CONFIG_E100=y
 # CONFIG_ACENIC is not set
 # CONFIG_DL2K is not set
 CONFIG_E1000=y
-# CONFIG_E1000_NAPI is not set
+CONFIG_E1000_NAPI=y
 # CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_NS83820 is not set
 # CONFIG_HAMACHI is not set
diff --git a/arch/sh/configs/r7780mp_defconfig b/arch/sh/configs/r7780mp_defconfig
index 1a07261..c65ece0 100644
--- a/arch/sh/configs/r7780mp_defconfig
+++ b/arch/sh/configs/r7780mp_defconfig
@@ -622,7 +622,7 @@ CONFIG_NETDEV_1000=y
 # CONFIG_ACENIC is not set
 # CONFIG_DL2K is not set
 CONFIG_E1000=m
-# CONFIG_E1000_NAPI is not set
+CONFIG_E1000_NAPI=y
 # CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_E1000E is not set
 # CONFIG_E1000E_ENABLED is not set
diff --git a/arch/x86/configs/i386_defconfig b/arch/x86/configs/i386_defconfig
index b738c78..e3f3349 100644
--- a/arch/x86/configs/i386_defconfig
+++ b/arch/x86/configs/i386_defconfig
@@ -812,7 +812,7 @@ CONFIG_NETDEV_1000=y
 # CONFIG_ACENIC is not set
 # CONFIG_DL2K is not set
 CONFIG_E1000=y
-# CONFIG_E1000_NAPI is not set
+CONFIG_E1000_NAPI=y
 # CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 CONFIG_E1000E=y
 # CONFIG_NS83820 is not set
diff --git a/arch/x86/configs/x86_64_defconfig b/arch/x86/configs/x86_64_defconfig
index 0fb202e..f23a68c 100644
--- a/arch/x86/configs/x86_64_defconfig
+++ b/arch/x86/configs/x86_64_defconfig
@@ -738,7 +738,7 @@ CONFIG_NETDEV_1000=y
 # CONFIG_ACENIC is not set
 # CONFIG_DL2K is not set
 CONFIG_E1000=y
-# CONFIG_E1000_NAPI is not set
+CONFIG_E1000_NAPI=y
 # CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 CONFIG_E1000E=y
 # CONFIG_NS83820 is not set


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft 
Defy all challenges. Microsoft(R) Visual Studio 2008. 
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
