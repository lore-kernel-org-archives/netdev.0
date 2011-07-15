From: Ian Campbell <ian.campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 02/10] mm: use const struct page for r/o page-flag accessor methods
Date: Fri, 15 Jul 2011 12:07:03 +0100
Message-ID: <1310728031-19569-2-git-send-email-ian.campbell@citrix.com>
References: <1310728006.20648.3.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ian Campbell <ian.campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1310728006.20648.3.camel-o4Be2W7LfRlXesXXhkcM7miJhflN2719@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ian Campbell <ian.campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
---
 include/linux/page-flags.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 6081493..7d632cc 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -135,7 +135,7 @@ enum pageflags {
  * Macros to create function definitions for page flags
  */
 #define TESTPAGEFLAG(uname, lname)					\
-static inline int Page##uname(struct page *page) 			\
+static inline int Page##uname(const struct page *page) 			\
 			{ return test_bit(PG_##lname, &page->flags); }
 
 #define SETPAGEFLAG(uname, lname)					\
@@ -173,7 +173,7 @@ static inline int __TestClearPage##uname(struct page *page)		\
 	__SETPAGEFLAG(uname, lname)  __CLEARPAGEFLAG(uname, lname)
 
 #define PAGEFLAG_FALSE(uname) 						\
-static inline int Page##uname(struct page *page) 			\
+static inline int Page##uname(const struct page *page) 			\
 			{ return 0; }
 
 #define TESTSCFLAG(uname, lname)					\
-- 
1.7.2.5

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
