From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] net: fix ifenslave build flags
Date: Thu, 10 Feb 2011 16:27:25 -0800
Message-ID: <4D54826D.3060406@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Alexey Salmin <alexey.salmin@gmail.com>
To: Netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:59715 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757171Ab1BKA2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Feb 2011 19:28:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

-I (include path) should be specified for host builds.
This one was overlooked somehow.  Fixes
https://bugzilla.kernel.org/show_bug.cgi?id=25902

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Reported-by: Alexey Salmin <alexey.salmin@gmail.com>
---
 Documentation/networking/Makefile |    2 ++
 1 file changed, 2 insertions(+)

--- lnx-2638-rc4.orig/Documentation/networking/Makefile
+++ lnx-2638-rc4/Documentation/networking/Makefile
@@ -4,6 +4,8 @@ obj- := dummy.o
 # List of programs to build
 hostprogs-y := ifenslave
 
+HOSTCFLAGS_ifenslave.o += -I$(objtree)/usr/include
+
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
 
