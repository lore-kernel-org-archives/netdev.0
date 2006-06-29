From: Bryan O'Sullivan <bos@pathscale.com>
Subject: [PATCH 35 of 39] IB/ipath - remove some #if 0 code related to
	lockable memory
Date: Thu, 29 Jun 2006 14:41:26 -0700
Message-ID: <9b423c45af8b2eb98562.1151617286@eng-12.pathscale.com>
References: <patchbomb.1151617251@eng-12.pathscale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: openib-general@openib.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.pathscale.com ([64.160.42.68]:40079 "EHLO mx.pathscale.com")
	by vger.kernel.org with ESMTP id S932914AbWF2VoK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2006 17:44:10 -0400
In-Reply-To: <patchbomb.1151617251@eng-12.pathscale.com>
To: akpm@osdl.org, rdreier@cisco.com, mst@mellanox.co.il
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Dave Olson <dave.olson@qlogic.com>
Signed-off-by: Bryan O'Sullivan <bryan.osullivan@qlogic.com>

diff -r b6ebaf2dd2fd -r 9b423c45af8b drivers/infiniband/hw/ipath/ipath_user_pages.c
--- a/drivers/infiniband/hw/ipath/ipath_user_pages.c	Thu Jun 29 14:33:26 2006 -0700
+++ b/drivers/infiniband/hw/ipath/ipath_user_pages.c	Thu Jun 29 14:33:26 2006 -0700
@@ -57,17 +57,6 @@ static int __get_user_pages(unsigned lon
 	unsigned long lock_limit;
 	size_t got;
 	int ret;
-
-#if 0
-	/*
-	 * XXX - causes MPI programs to fail, haven't had time to check
-	 * yet
-	 */
-	if (!capable(CAP_IPC_LOCK)) {
-		ret = -EPERM;
-		goto bail;
-	}
-#endif
 
 	lock_limit = current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur >>
 		PAGE_SHIFT;
