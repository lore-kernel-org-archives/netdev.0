From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 11/12] headers, scc: Add missing #include to <linux/scc.h>
Date: Mon, 08 Aug 2011 14:24:29 +0100
Message-ID: <1312809869.2591.1151.camel@deadeye>
References: <1312809302.2591.1139.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, Joerg Reuter <jreuter@yaina.de>,
	Klaus Kudielka <klaus.kudielka@ieee.org>,
	linux-hams@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <1312809302.2591.1139.camel@deadeye>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

<linux/scc.h> uses SIOCDEVPRIVATE, defined in <linux/sockios.h>.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
This file isn't listed in MAINTAINERS but appears to be associated with
one of the hamradio drivers; please could one of the hams claim it?

Ben.

 include/linux/scc.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/scc.h b/include/linux/scc.h
index 3495bd9..d5916e5 100644
--- a/include/linux/scc.h
+++ b/include/linux/scc.h
@@ -3,6 +3,7 @@
 #ifndef	_SCC_H
 #define	_SCC_H
 
+#include <linux/sockios.h>
 
 /* selection of hardware types */
 
-- 
1.7.5.4



