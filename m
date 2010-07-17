From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] Remove MAX_SOCK_ADDR constant
Date: Sat, 17 Jul 2010 21:38:05 +0900
Message-ID: <201007172138.GJF90644.VFOSFFMOLJHtQO@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wine.ocn.ne.jp ([122.1.235.145]:56850 "EHLO smtp.wine.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753906Ab0GQMiL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Jul 2010 08:38:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From b976a4d6c4d2a76e3926193eba366781adcb533c Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 17 Jul 2010 21:29:53 +0900
Subject: [PATCH] Remove MAX_SOCK_ADDR constant

MAX_SOCK_ADDR is no longer used because commit 230b1839 "net: Use standard
structures for generic socket address structures." replaced
"char address[MAX_SOCK_ADDR];" with "struct sockaddr_storage address;".

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 net/socket.c |    9 ---------
 1 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index 367d547..2336ac5 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -170,15 +170,6 @@ static DEFINE_PER_CPU(int, sockets_in_use) = 0;
  * divide and look after the messy bits.
  */
 
-#define MAX_SOCK_ADDR	128		/* 108 for Unix domain -
-					   16 for IP, 16 for IPX,
-					   24 for IPv6,
-					   about 80 for AX.25
-					   must be at least one bigger than
-					   the AF_UNIX size (see net/unix/af_unix.c
-					   :unix_mkname()).
-					 */
-
 /**
  *	move_addr_to_kernel	-	copy a socket address into kernel space
  *	@uaddr: Address in user space
-- 
1.6.1
