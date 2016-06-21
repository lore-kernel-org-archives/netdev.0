From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2] Enable use of extra debugging information
Date: Tue, 21 Jun 2016 16:27:09 -0700
Message-ID: <1466551629-7921-1-git-send-email-dsa@cumulusnetworks.com>
Cc: stephen@networkplumber.org, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35905 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751374AbcFUX2u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 19:28:50 -0400
Received: by mail-pa0-f48.google.com with SMTP id wo6so10560919pac.3
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 16:27:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add -g flag to builds if DEBUG parameter is set. Improves
debugging with gdb.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 Makefile | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/Makefile b/Makefile
index 15c81ecfdca3..8e006759079d 100644
--- a/Makefile
+++ b/Makefile
@@ -39,7 +39,11 @@ HOSTCC = gcc
 DEFINES += -D_GNU_SOURCE
 # Turn on transparent support for LFS
 DEFINES += -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE
+ifdef DEBUG
+CCOPTS = -g
+else
 CCOPTS = -O2
+endif
 WFLAGS := -Wall -Wstrict-prototypes  -Wmissing-prototypes
 WFLAGS += -Wmissing-declarations -Wold-style-definition -Wformat=2
 
-- 
2.1.4
