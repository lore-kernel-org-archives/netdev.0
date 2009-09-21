From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH] iproute2: use -fPIC in lib/
Date: Mon, 21 Sep 2009 09:47:51 +0200
Message-ID: <20090921074751.GA17570@amd64.fatal.se>
References: <39840bc80909201712o65b1c84m1bc453bf9d4329a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Baryshev <ksquirrel.iv@gmail.com>, 547602@bugs.debian.org
To: shemminger@vyatta.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxy1.bredband.net ([195.54.101.71]:36804 "EHLO
	proxy1.bredband.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751928AbZIUHsK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2009 03:48:10 -0400
Received: from iph1.telenor.se (195.54.127.132) by proxy1.bredband.net (7.3.140.3)
        id 49F5A15203994EC6 for netdev@vger.kernel.org; Mon, 21 Sep 2009 09:48:09 +0200
Content-Disposition: inline
In-Reply-To: <39840bc80909201712o65b1c84m1bc453bf9d4329a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The static libnetlink.a library is exposed to other users in Debian via the
"iproute-dev" package. Apparently people are interested in using it in their
shared libraries and would like to see the code be position independent.

Patch below makes the code under lib/ build with -fPIC.

See http://bugs.debian.org/547602

Signed-off-by: Andreas Henriksson <andreas@fatal.se>

diff --git a/lib/Makefile b/lib/Makefile
index bc270bf..da2f0fc 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -1,3 +1,4 @@
+CFLAGS += -fPIC
 
 UTILOBJ=utils.o rt_names.o ll_types.o ll_proto.o ll_addr.o inet_proto.o
 
