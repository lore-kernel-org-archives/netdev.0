From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 3/3] wimax: testing for rfkill support should also test for
	CONFIG_RFKILL_MODULE
Date: Wed,  7 Jan 2009 09:18:47 -0800
Message-ID: <ce4d7f71df1471d502e02861a7db65cbb2a5548f.1231348339.git.inaky@linux.intel.com>
References: <cover.1231348339.git.inaky@linux.intel.com>
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>, wimax@linuxwimax.org,
	greg@kroah.com, LKML <linux-kernel@vger.kernel.org>,
	linux-wimax@intel.com, linux-next@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <cover.1231348339.git.inaky@linux.intel.com>
List-Unsubscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.moblin.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

Current WiMAX rfkill code is missing the case where rfkill is compiled
in as modules and works only when rfkill is compiled in. This is not
correct. Fixed to test for CONFIG_RFKILL or CONFIG_RKILL_MODULE.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 net/wimax/op-rfkill.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/wimax/op-rfkill.c b/net/wimax/op-rfkill.c
index 8745bac..2b75aee 100644
--- a/net/wimax/op-rfkill.c
+++ b/net/wimax/op-rfkill.c
@@ -71,7 +71,7 @@
 #define D_SUBMODULE op_rfkill
 #include "debug-levels.h"
 
-#ifdef CONFIG_RFKILL
+#if defined(CONFIG_RFKILL) || defined(CONFIG_RFKILL_MODULE)
 
 
 /**
-- 
1.5.6.5
