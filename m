From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: patches for PROC_FS=n (2.6.0-test7)
Date: Sun, 12 Oct 2003 19:17:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031012191725.093139d5.rddunlap@osdl.org>
References: <Pine.GSO.4.58.0310101519330.9806@inky>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, davem@redhat.com, maxk@qualcomm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Noah J. Misch" <noah@caltech.edu>
In-Reply-To: <Pine.GSO.4.58.0310101519330.9806@inky>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 10 Oct 2003 16:06:29 -0700 (PDT) "Noah J. Misch" <noah@caltech.edu> wrote:

| > There are several other drivers/protocols that don't build
| > with PROC_FS=n, like arlan, siimage, ipx, llc, and bluetooth.
| 
| I put in a patch for ipx yesterday, and I have patches for siimage and llc
| pretty much ready to go.  I noticed the others but I have not done much.

ipx is merged.  I'll leave siimage and llc to Noah.
Patch below fixes af_bluetooth.  Comments on it?

--
~Randy


patch_name:	bt_noprocfs.patch
patch_version:	2003-10-12.19:11:03
author:		Randy.Dunlap <rddunlap@osdl.org>
description:	af_bluetooth uses/needs proc_bt when PROC_FS=n
product:	Linux
product_versions: 2.6.0-test7
diffstat:	=
 net/bluetooth/af_bluetooth.c |    2 --
 1 files changed, 2 deletions(-)


diff -Naur ./net/bluetooth/af_bluetooth.c~btprocfs ./net/bluetooth/af_bluetooth.c
--- ./net/bluetooth/af_bluetooth.c~btprocfs	2003-10-08 12:24:02.000000000 -0700
+++ ./net/bluetooth/af_bluetooth.c	2003-10-12 19:09:11.000000000 -0700
@@ -56,9 +56,7 @@
 #define BT_DBG( A... )
 #endif
 
-#ifdef CONFIG_PROC_FS
 struct proc_dir_entry *proc_bt;
-#endif
 
 /* Bluetooth sockets */
 #define BT_MAX_PROTO	5
