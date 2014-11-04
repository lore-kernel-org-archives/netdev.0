From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] ipv4: include linux/bug.h instead of asm/bug.h
Date: Tue,  4 Nov 2014 20:13:50 +0100
Message-ID: <1415128430-10674-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/ipv4/cipso_ipv4.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
index 4715f25..a7cc798 100644
--- a/net/ipv4/cipso_ipv4.c
+++ b/net/ipv4/cipso_ipv4.c
@@ -50,7 +50,7 @@
 #include <net/netlabel.h>
 #include <net/cipso_ipv4.h>
 #include <linux/atomic.h>
-#include <asm/bug.h>
+#include <linux/bug.h>
 #include <asm/unaligned.h>
 
 /* List of available DOI definitions */
-- 
1.9.3
