From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 08/13] timer: Remove unused static initializer macros
Date: Wed,  4 Oct 2017 16:27:02 -0700
Message-ID: <1507159627-127660-9-git-send-email-keescook@chromium.org>
References: <1507159627-127660-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Arnd Bergmann <arnd@arndb.de>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Chris Metcalf <cmetcalf@mellanox.com>,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Guenter Roeck <linux@roeck-us.net>,
        Harish Patil <harish.patil@cavium.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        John Stultz <john.stultz@linaro.org>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>,
        Kalle Valo <kvalo@qca.qualcomm.com>,
        Lai Jiangshan <jiangshanlai@gmail.com>,
        Len Brown <len.brown@intel.com>,
        Manish Chopra <manish.chopra@cavium.com>,
        Mark Gross <mark.gross@intel.com>,
        "Martin K. Petersen" <ma
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1507159627-127660-1-git-send-email-keescook@chromium.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

This removes the now unused TIMER_*INITIALIZER macros:

TIMER_INITIALIZER
TIMER_PINNED_INITIALIZER
TIMER_DEFERRED_INITIALIZER
TIMER_PINNED_DEFERRED_INITIALIZER

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 include/linux/timer.h | 12 ------------
 1 file changed, 12 deletions(-)

diff --git a/include/linux/timer.h b/include/linux/timer.h
index 4f7476e4a727..a33220311361 100644
--- a/include/linux/timer.h
+++ b/include/linux/timer.h
@@ -73,18 +73,6 @@ struct timer_list {
 			__FILE__ ":" __stringify(__LINE__))	\
 	}
 
-#define TIMER_INITIALIZER(_function, _expires, _data)		\
-	__TIMER_INITIALIZER((_function), (_expires), (_data), 0)
-
-#define TIMER_PINNED_INITIALIZER(_function, _expires, _data)	\
-	__TIMER_INITIALIZER((_function), (_expires), (_data), TIMER_PINNED)
-
-#define TIMER_DEFERRED_INITIALIZER(_function, _expires, _data)	\
-	__TIMER_INITIALIZER((_function), (_expires), (_data), TIMER_DEFERRABLE)
-
-#define TIMER_PINNED_DEFERRED_INITIALIZER(_function, _expires, _data)	\
-	__TIMER_INITIALIZER((_function), (_expires), (_data), TIMER_DEFERRABLE | TIMER_PINNED)
-
 #define DEFINE_TIMER(_name, _function, _expires, _data)		\
 	struct timer_list _name =				\
 		__TIMER_INITIALIZER(_function, _expires, _data, 0)
-- 
2.7.4
