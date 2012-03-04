From: Paul Mackerras <paulus@samba.org>
Subject: [PATCH 1/3] ppp: Change copyright notices from ANU to me
Date: Mon, 5 Mar 2012 09:54:54 +1100
Message-ID: <20120304225453.GB10646@bloggs.ozlabs.ibm.com>
References: <20120304225336.GA10646@bloggs.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Kiszka <jan.kiszka@siemens.com>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120304225336.GA10646@bloggs.ozlabs.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This changes the copyright notices on the PPP code that I developed
in the late 1990s from being copyright The Australian National
University to copyright Paul Mackerras.  I can do this as I have an
acknowledgement in writing from the Head of the Computer Science
Department at ANU (where I worked then) that ANU does not claim any
intellectual property in this code.

While I'm at it, change the copyright notice from BSD-style to
GNU GPL like the rest of the kernel.

Signed-off-by: Paul Mackerras <paulus@samba.org>
---
 drivers/net/ppp/ppp_deflate.c |   30 ++++--------------------------
 include/linux/ppp-comp.h      |   38 ++++----------------------------------
 include/linux/ppp_defs.h      |   38 ++++----------------------------------
 3 files changed, 12 insertions(+), 94 deletions(-)

diff --git a/drivers/net/ppp/ppp_deflate.c b/drivers/net/ppp/ppp_deflate.c
index 1dbdf82..602c625 100644
--- a/drivers/net/ppp/ppp_deflate.c
+++ b/drivers/net/ppp/ppp_deflate.c
@@ -1,34 +1,12 @@
 /*
- *  ==FILEVERSION 980319==
- *
  * ppp_deflate.c - interface the zlib procedures for Deflate compression
  * and decompression (as used by gzip) to the PPP code.
- * This version is for use with Linux kernel 1.3.X.
- *
- * Copyright (c) 1994 The Australian National University.
- * All rights reserved.
- *
- * Permission to use, copy, modify, and distribute this software and its
- * documentation is hereby granted, provided that the above copyright
- * notice appears in all copies.  This software is provided without any
- * warranty, express or implied. The Australian National University
- * makes no representations about the suitability of this software for
- * any purpose.
- *
- * IN NO EVENT SHALL THE AUSTRALIAN NATIONAL UNIVERSITY BE LIABLE TO ANY
- * PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
- * ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF
- * THE AUSTRALIAN NATIONAL UNIVERSITY HAS BEEN ADVISED OF THE POSSIBILITY
- * OF SUCH DAMAGE.
  *
- * THE AUSTRALIAN NATIONAL UNIVERSITY SPECIFICALLY DISCLAIMS ANY WARRANTIES,
- * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
- * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
- * ON AN "AS IS" BASIS, AND THE AUSTRALIAN NATIONAL UNIVERSITY HAS NO
- * OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS,
- * OR MODIFICATIONS.
+ * Copyright 1994-1998 Paul Mackerras.
  *
- * From: deflate.c,v 1.1 1996/01/18 03:17:48 paulus Exp
+ *  This program is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU General Public License
+ *  version 2 as published by the Free Software Foundation.
  */
 
 #include <linux/module.h>
diff --git a/include/linux/ppp-comp.h b/include/linux/ppp-comp.h
index b8d4ddd..e53ff65 100644
--- a/include/linux/ppp-comp.h
+++ b/include/linux/ppp-comp.h
@@ -1,42 +1,12 @@
 /*
  * ppp-comp.h - Definitions for doing PPP packet compression.
  *
- * Copyright (c) 1994 The Australian National University.
- * All rights reserved.
+ * Copyright 1994-1998 Paul Mackerras.
  *
- * Permission to use, copy, modify, and distribute this software and its
- * documentation is hereby granted, provided that the above copyright
- * notice appears in all copies.  This software is provided without any
- * warranty, express or implied. The Australian National University
- * makes no representations about the suitability of this software for
- * any purpose.
- *
- * IN NO EVENT SHALL THE AUSTRALIAN NATIONAL UNIVERSITY BE LIABLE TO ANY
- * PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
- * ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF
- * THE AUSTRALIAN NATIONAL UNIVERSITY HAVE BEEN ADVISED OF THE POSSIBILITY
- * OF SUCH DAMAGE.
- *
- * THE AUSTRALIAN NATIONAL UNIVERSITY SPECIFICALLY DISCLAIMS ANY WARRANTIES,
- * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
- * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
- * ON AN "AS IS" BASIS, AND THE AUSTRALIAN NATIONAL UNIVERSITY HAS NO
- * OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS,
- * OR MODIFICATIONS.
+ *  This program is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU General Public License
+ *  version 2 as published by the Free Software Foundation.
  */
-
-/*
- *  ==FILEVERSION 980319==
- *
- *  NOTE TO MAINTAINERS:
- *     If you modify this file at all, please set the above date.
- *     ppp-comp.h is shipped with a PPP distribution as well as with the kernel;
- *     if everyone increases the FILEVERSION number above, then scripts
- *     can do the right thing when deciding whether to install a new ppp-comp.h
- *     file.  Don't change the format of that line otherwise, so the
- *     installation script can recognize it.
- */
-
 #ifndef _NET_PPP_COMP_H
 #define _NET_PPP_COMP_H
 
diff --git a/include/linux/ppp_defs.h b/include/linux/ppp_defs.h
index 0f93ed6..ba416f6 100644
--- a/include/linux/ppp_defs.h
+++ b/include/linux/ppp_defs.h
@@ -1,44 +1,14 @@
 /*
  * ppp_defs.h - PPP definitions.
  *
- * Copyright (c) 1994 The Australian National University.
- * All rights reserved.
+ * Copyright 1994-2000 Paul Mackerras.
  *
- * Permission to use, copy, modify, and distribute this software and its
- * documentation is hereby granted, provided that the above copyright
- * notice appears in all copies.  This software is provided without any
- * warranty, express or implied. The Australian National University
- * makes no representations about the suitability of this software for
- * any purpose.
- *
- * IN NO EVENT SHALL THE AUSTRALIAN NATIONAL UNIVERSITY BE LIABLE TO ANY
- * PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
- * ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF
- * THE AUSTRALIAN NATIONAL UNIVERSITY HAVE BEEN ADVISED OF THE POSSIBILITY
- * OF SUCH DAMAGE.
- *
- * THE AUSTRALIAN NATIONAL UNIVERSITY SPECIFICALLY DISCLAIMS ANY WARRANTIES,
- * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
- * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
- * ON AN "AS IS" BASIS, AND THE AUSTRALIAN NATIONAL UNIVERSITY HAS NO
- * OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS,
- * OR MODIFICATIONS.
+ *  This program is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU General Public License
+ *  version 2 as published by the Free Software Foundation.
  */
-
 #include <linux/types.h>
 
-/*
- *  ==FILEVERSION 20000114==
- *
- *  NOTE TO MAINTAINERS:
- *     If you modify this file at all, please set the above date.
- *     ppp_defs.h is shipped with a PPP distribution as well as with the kernel;
- *     if everyone increases the FILEVERSION number above, then scripts
- *     can do the right thing when deciding whether to install a new ppp_defs.h
- *     file.  Don't change the format of that line otherwise, so the
- *     installation script can recognize it.
- */
-
 #ifndef _PPP_DEFS_H_
 #define _PPP_DEFS_H_
 
-- 
1.7.9.1
