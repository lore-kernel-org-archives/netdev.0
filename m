From: Wolfgang Grandegger <wg@grandegger.com>
Subject: [PATCH 1/2] iproute2: Fixes an issue with cross-compilation
Date: Tue, 12 May 2009 11:42:49 +0200
Message-ID: <20090512094248.614764546@denx.de>
References: <20090512094248.439786706@denx.de>
Cc: linux-kernel@vger.kernel.org,
	Wolfgang Grandegger <wg@grandegger.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:44832 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750709AbZELJmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 05:42:49 -0400
Content-Disposition: inline; filename=01-cross-compilation.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>
---
 Makefile |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: iproute2/Makefile
===================================================================
--- iproute2.orig/Makefile
+++ iproute2/Makefile
@@ -1,4 +1,5 @@
 DESTDIR=/usr/
+ROOTDIR=$(DESTDIR)
 LIBDIR=/usr/lib/
 SBINDIR=/sbin
 CONFDIR=/etc/iproute2
@@ -7,7 +8,7 @@ MANDIR=/share/man
 ARPDDIR=/var/lib/arpd
 
 # Path to db_185.h include
-DBM_INCLUDE:=/usr/include
+DBM_INCLUDE:=$(ROOTDIR)/usr/include
 
 DEFINES= -DRESOLVE_HOSTNAMES -DLIBDIR=\"$(LIBDIR)\"
 

