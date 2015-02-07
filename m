From: Bas Peters <baspeters93@gmail.com>
Subject: [PATCH 7/7] drivers: isdn: act2000: capi.c: add macro \ and fix brace
Date: Sat,  7 Feb 2015 20:05:29 +0100
Message-ID: <1423335929-24926-8-git-send-email-baspeters93@gmail.com>
References: <1423335929-24926-1-git-send-email-baspeters93@gmail.com>
Cc: julia.lawall@lip6.fr, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	Bas Peters <baspeters93@gmail.com>
To: isdn@linux-pingi.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423335929-24926-1-git-send-email-baspeters93@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds the \ that was accidentally deleted in patch 2. It also adds a brace after the else statement, which is required due to the fact that the if statement has braces.

---
 drivers/isdn/act2000/capi.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/isdn/act2000/capi.c b/drivers/isdn/act2000/capi.c
index 5d677e6..0043b3c 100644
--- a/drivers/isdn/act2000/capi.c
+++ b/drivers/isdn/act2000/capi.c
@@ -113,8 +113,9 @@ actcapi_chkhdr(act2000_card *card, actcapi_msghdr *hdr)
 			m->hdr.cmd.cmd = c;			\
 			m->hdr.cmd.subcmd = s;			\
 			m->hdr.msgnum = actcapi_nextsmsg(card); \
-		} else
+		} else {					\
 			m = NULL;				\
+		}						\
 	}
 
 #define ACTCAPI_CHKSKB if (!skb) {					\
-- 
2.1.0
