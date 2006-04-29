From: Ralf Baechle <ralf@linux-mips.org>
Subject: [ROSE] Remove useless prototype for rose_remove_neigh().
Date: Sat, 29 Apr 2006 14:25:53 +0100
Message-ID: <20060429132553.GA31622@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:52625 "EHLO
	ftp.linux-mips.org") by vger.kernel.org with ESMTP id S1750781AbWD2Sj5
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Apr 2006 14:39:57 -0400
Received: from localhost.localdomain ([127.0.0.1]:17067 "EHLO bacchus.dhis.org")
	by ftp.linux-mips.org with ESMTP id S8133567AbWD2Sjy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Apr 2006 19:39:54 +0100
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

 net/rose/rose_route.c |    2 --
 1 file changed, 2 deletions(-)

Index: linux-net.git/net/rose/rose_route.c
===================================================================
--- linux-net.git.orig/net/rose/rose_route.c	2006-04-29 14:18:02.000000000 +0100
+++ linux-net.git/net/rose/rose_route.c	2006-04-29 14:18:58.000000000 +0100
@@ -48,8 +48,6 @@ static DEFINE_SPINLOCK(rose_route_list_l
 
 struct rose_neigh *rose_loopback_neigh;
 
-static void rose_remove_neigh(struct rose_neigh *);
-
 /*
  *	Add a new route to a node, and in the process add the node and the
  *	neighbour if it is new.
