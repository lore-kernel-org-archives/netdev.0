From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 3/3] wimax: testing for rfkill support should also test for
	CONFIG_RFKILL_MODULE
Date: Tue,  6 Jan 2009 23:58:22 -0800
Message-ID: <2683eec8eab0a647089cd4c8fc1b1daac44e9bdb.1231314782.git.inaky@linux.intel.com>
References: <cover.1231314782.git.inaky@linux.intel.com>
Cc: greg@kroah.com, wimax@linuxwimax.org
To: netdev@vger.kernel.org
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <cover.1231314782.git.inaky@linux.intel.com>
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
