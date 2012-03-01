From: "Christoph J. Thompson" <cjsthompson@gmail.com>
Subject: [PATCH 2/4] iproute2 - Split up cflags. Allows setting optimisation
 flags at compile time without patching the Makefile.
Date: Thu, 1 Mar 2012 17:45:17 +0100
Message-ID: <20120301164514.GA24274@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:39450 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756400Ab2CAQpJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2012 11:45:09 -0500
Received: by wibhm2 with SMTP id hm2so53632wib.19
        for <netdev@vger.kernel.org>; Thu, 01 Mar 2012 08:45:08 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	modified:   Makefile

Signed-off-by: Christoph J. Thompson <cjsthompson@gmail.com>
---
 Makefile |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/Makefile b/Makefile
index c6e4943..014d497 100644
--- a/Makefile
+++ b/Makefile
@@ -29,8 +29,10 @@ ADDLIB+=ipx_ntop.o ipx_pton.o
 
 CC = gcc
 HOSTCC = gcc
-CCOPTS = -D_GNU_SOURCE -O2 -Wstrict-prototypes -Wall
-CFLAGS = $(CCOPTS) -I../include $(DEFINES)
+DEFINES += -D_GNU_SOURCE
+CCOPTS = -O2
+WFLAGS = -Wall -Wstrict-prototypes
+CFLAGS = $(WFLAGS) $(CCOPTS) -I../include $(DEFINES)
 YACCFLAGS = -d -t -v
 
 SUBDIRS=lib ip tc misc netem genl
-- 
1.7.4.4


-- 
Jabber: heimdal@jabber.org
