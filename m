From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v4 5/5] Makefile: Allow to override CC
Date: Wed, 13 Jul 2016 20:47:19 +0200
Message-ID: <1468435639-6892-6-git-send-email-phil@nwl.cc>
References: <1468435639-6892-1-git-send-email-phil@nwl.cc>
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Julien Floret <julien.floret@6wind.com>,
	David Laight <David.Laight@ACULAB.COM>, netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:54461 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751507AbcGMSrd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2016 14:47:33 -0400
In-Reply-To: <1468435639-6892-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This makes it easier to build iproute2 with a custom compiler.

While at it, make HOSTCC default to the value of CC if not explicitly
set elsewhere.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 Makefile | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/Makefile b/Makefile
index 15c81ecfdca3a..fa200ddb76679 100644
--- a/Makefile
+++ b/Makefile
@@ -34,8 +34,8 @@ ADDLIB+=ipx_ntop.o ipx_pton.o
 #options for mpls
 ADDLIB+=mpls_ntop.o mpls_pton.o
 
-CC = gcc
-HOSTCC = gcc
+CC := gcc
+HOSTCC ?= $(CC)
 DEFINES += -D_GNU_SOURCE
 # Turn on transparent support for LFS
 DEFINES += -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE
-- 
2.8.2
