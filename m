From: Shan Wei <shanwei88@gmail.com>
Subject: [PATCH] tcp: doc : fix the syncookies default value
Date: Fri, 21 Jun 2013 15:18:32 +0800
Message-ID: <51C3FE48.2060804@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: davidshan@tencent.com
To: davem@davemloft.net, linux-doc@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


syncookies is on for default since in commit e994b7c901
(tcp: Don't make syn cookies initial setting depend on CONFIG_SYSCTL).

And fix a typo of CONFIG_SYN_COOKIES.

Signed-off-by: Shan Wei <davidshan@tencent.com>
---
 Documentation/networking/ip-sysctl.txt |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 36e5a40..1074290 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -420,10 +420,10 @@ tcp_synack_retries - INTEGER
 	for a passive TCP connection will happen after 63seconds.
 
 tcp_syncookies - BOOLEAN
-	Only valid when the kernel was compiled with CONFIG_SYNCOOKIES
+	Only valid when the kernel was compiled with CONFIG_SYN_COOKIES
 	Send out syncookies when the syn backlog queue of a socket
 	overflows. This is to prevent against the common 'SYN flood attack'
-	Default: FALSE
+	Default: 1
 
 	Note, that syncookies is fallback facility.
 	It MUST NOT be used to help highly loaded servers to stand
-- 
1.7.1

