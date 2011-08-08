From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 02/12] headers, ax25: Add missing #include to
 <linux/netrom.h>, <linux/rose.h>
Date: Mon, 08 Aug 2011 14:17:20 +0100
Message-ID: <1312809440.2591.1141.camel@deadeye>
References: <1312809302.2591.1139.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>,
	linux-hams@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <1312809302.2591.1139.camel@deadeye>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These headers use the ax25_address type defined in <linux/ax25.h>.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/linux/netrom.h |    2 ++
 include/linux/rose.h   |    2 ++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/linux/netrom.h b/include/linux/netrom.h
index 6939b32..af7313c 100644
--- a/include/linux/netrom.h
+++ b/include/linux/netrom.h
@@ -7,6 +7,8 @@
 #ifndef	NETROM_KERNEL_H
 #define	NETROM_KERNEL_H
 
+#include <linux/ax25.h>
+
 #define NETROM_MTU	236
 
 #define NETROM_T1	1
diff --git a/include/linux/rose.h b/include/linux/rose.h
index c7b4b18..e8289cd 100644
--- a/include/linux/rose.h
+++ b/include/linux/rose.h
@@ -7,6 +7,8 @@
 #ifndef	ROSE_KERNEL_H
 #define	ROSE_KERNEL_H
 
+#include <linux/ax25.h>
+
 #define ROSE_MTU	251
 
 #define ROSE_MAX_DIGIS 6
-- 
1.7.5.4



