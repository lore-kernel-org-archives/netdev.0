From: Daniele Venzano <webvenza@libero.it>
Subject: [PATCH 2/5] sis900 printk audit
Date: Sat, 22 Jan 2005 22:46:58 +0100 (CET)
Message-ID: <20050122214658.18649.32654@localhost.localdomain>
References: <20050122214657.18649.66345@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; charset="us-ascii";
	boundary="===============1012319623=="
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20050122214657.18649.66345@localhost.localdomain>
To: Jeff Garzik <jgarzik@pobox.com>, NetDev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a MIME message, see the first attachment for the text
and the second for the patch
--===============1012319623==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit



Version bump
Remove broken link to documentation



Signed-off-by: Daniele Venzano <webvenza@libero.it>


--===============1012319623==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit

Index: sis900.c
===================================================================
--- a/drivers/net/sis900.c	(revision 84)
+++ b/drivers/net/sis900.c	(revision 85)
@@ -1,6 +1,6 @@
 /* sis900.c: A SiS 900/7016 PCI Fast Ethernet driver for Linux.
    Copyright 1999 Silicon Integrated System Corporation 
-   Revision:	1.08.06 Sep. 24 2002
+   Revision:	1.08.08 Jan. 22 2005
    
    Modified from the driver which is originally written by Donald Becker.
    
@@ -16,8 +16,8 @@
    preliminary Rev. 1.0 Nov. 10, 1998
    SiS 7014 Single Chip 100BASE-TX/10BASE-T Physical Layer Solution,
    preliminary Rev. 1.0 Jan. 18, 1998
-   http://www.sis.com.tw/support/databook.htm
 
+   Rev 1.08.08 Jan. 22 2005 Daniele Venzano use netif_msg for debugging messages
    Rev 1.08.07 Nov.  2 2003 Daniele Venzano <webvenza@libero.it> add suspend/resume support
    Rev 1.08.06 Sep. 24 2002 Mufasa Yang bug fix for Tx timeout & add SiS963 support
    Rev 1.08.05 Jun.  6 2002 Mufasa Yang bug fix for read_eeprom & Tx descriptor over-boundary
@@ -74,7 +74,7 @@
 #include "sis900.h"
 
 #define SIS900_MODULE_NAME "sis900"
-#define SIS900_DRV_VERSION "v1.08.07 11/02/2003"
+#define SIS900_DRV_VERSION "v1.08.08 Jan. 22 2005"
 
 static char version[] __devinitdata =
 KERN_INFO "sis900.c: " SIS900_DRV_VERSION "\n";

--===============1012319623==--
