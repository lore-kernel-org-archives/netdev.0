From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 08/31] staging: r8188eu: Remove daemonize conditional
Date: Sun, 22 Dec 2013 17:36:39 -0600
Message-ID: <1387755422-11443-9-git-send-email-Larry.Finger@lwfinger.net>
References: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

The current kernels do not include this entry point. Delete the call.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/include/osdep_service.h | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/staging/rtl8188eu/include/osdep_service.h b/drivers/staging/rtl8188eu/include/osdep_service.h
index 6dc0707..b36fc20 100644
--- a/drivers/staging/rtl8188eu/include/osdep_service.h
+++ b/drivers/staging/rtl8188eu/include/osdep_service.h
@@ -284,9 +284,6 @@ static inline unsigned char _cancel_timer_ex(struct timer_list *ptimer)
 
 static inline void thread_enter(char *name)
 {
-#ifdef daemonize
-	daemonize("%s", name);
-#endif
 	allow_signal(SIGTERM);
 }
 
-- 
1.8.4
