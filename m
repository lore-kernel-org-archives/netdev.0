From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] ipv6: include linux/uaccess.h instead of asm/uaccess.h
Date: Mon, 27 Oct 2014 19:12:58 +0100
Message-ID: <1414433578-29321-1-git-send-email-fabf@skynet.be>
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
 net/ipv6/exthdrs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index bfde361..601d896 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -47,7 +47,7 @@
 #include <net/xfrm.h>
 #endif
 
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 
 /*
  *	Parsing tlv encoded headers.
-- 
1.9.1
