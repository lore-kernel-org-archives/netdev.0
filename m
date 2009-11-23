From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH] iproute2: use -fPIC in lib/
Date: Mon, 23 Nov 2009 11:03:52 +0100
Message-ID: <20091123100352.GA14356@amd64.fatal.se>
References: <39840bc80909201712o65b1c84m1bc453bf9d4329a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Dmitry Baryshev <ksquirrel.iv@gmail.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxy3.bredband.net ([195.54.101.73]:43543 "EHLO
	proxy3.bredband.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775AbZKWKDp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 05:03:45 -0500
Received: from ipb1.telenor.se (195.54.127.164) by proxy3.bredband.net (7.3.140.3)
        id 4AD3E1BA011E44AB for netdev@vger.kernel.org; Mon, 23 Nov 2009 11:03:51 +0100
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

---

Resending patch since no comments has been received and it has not
appeared in the iproute git repository.


diff --git a/lib/Makefile b/lib/Makefile
index bc270bf..da2f0fc 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -1,3 +1,4 @@
+CFLAGS += -fPIC
 
 UTILOBJ=utils.o rt_names.o ll_types.o ll_proto.o ll_addr.o inet_proto.o
 
