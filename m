From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 12/12] headers, ppp: Add missing #include to
 <linux/if_ppp.h>
Date: Mon, 08 Aug 2011 14:25:19 +0100
Message-ID: <1312809919.2591.1152.camel@deadeye>
References: <1312809302.2591.1139.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, Paul Mackerras <paulus@samba.org>,
	linux-ppp@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <1312809302.2591.1139.camel@deadeye>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

<linux/if_ppp.h> uses various types defined in <linux/ppp_defs.h>.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/linux/if_ppp.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_ppp.h b/include/linux/if_ppp.h
index c9ad383..4d70e16 100644
--- a/include/linux/if_ppp.h
+++ b/include/linux/if_ppp.h
@@ -35,6 +35,7 @@
 
 #include <linux/types.h>
 #include <linux/compiler.h>
+#include <linux/ppp_defs.h>
 
 /*
  * Packet sizes
-- 
1.7.5.4


