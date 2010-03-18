From: James Chapman <jchapman@katalix.com>
Subject: [RFC PATCH 1/2] iproute2: Add libnl support.
Date: Thu, 18 Mar 2010 18:14:21 +0000
Message-ID: <20100318181421.6862.72693.stgit@bert.katalix.com>
References: <20100318181416.6862.60894.stgit@bert.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:48176 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752548Ab0CRSOV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Mar 2010 14:14:21 -0400
In-Reply-To: <20100318181416.6862.60894.stgit@bert.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch links the ip utility with libnl, which must be separately
installed. This lets new functionality use libnl to implement its
netlink interfaces.

Package developers will need to add libnl to the iproute2 package
dependencies.
---
 Makefile |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/Makefile b/Makefile
index 77a85c6..c47435d 100644
--- a/Makefile
+++ b/Makefile
@@ -33,7 +33,7 @@ CCOPTS = -D_GNU_SOURCE -O2 -Wstrict-prototypes -Wall
 CFLAGS = $(CCOPTS) -I../include $(DEFINES)
 YACCFLAGS = -d -t -v
 
-LDLIBS += -L../lib -lnetlink -lutil
+LDLIBS += -L../lib -lnetlink -lutil -lnl
 
 SUBDIRS=lib ip tc misc netem genl
 

