From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] linux/net.h: fix kernel-doc warnings
Date: Thu, 1 Jul 2010 16:18:58 -0700
Message-ID: <20100701161858.a24a5803.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:44383 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750875Ab0GAXTw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jul 2010 19:19:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix kernel-doc warnings in linux/net.h:

Warning(include/linux/net.h:151): No description found for parameter 'wq'
Warning(include/linux/net.h:151): Excess struct/union/enum/typedef member 'fasync_list' description in 'socket'
Warning(include/linux/net.h:151): Excess struct/union/enum/typedef member 'wait' description in 'socket'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 include/linux/net.h |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

--- linux-2.6.35-rc3-git5.orig/include/linux/net.h
+++ linux-2.6.35-rc3-git5/include/linux/net.h
@@ -129,10 +129,9 @@ struct socket_wq {
  *  @type: socket type (%SOCK_STREAM, etc)
  *  @flags: socket flags (%SOCK_ASYNC_NOSPACE, etc)
  *  @ops: protocol specific socket operations
- *  @fasync_list: Asynchronous wake up list
  *  @file: File back pointer for gc
  *  @sk: internal networking protocol agnostic socket representation
- *  @wait: wait queue for several uses
+ *  @wq: wait queue for several uses
  */
 struct socket {
 	socket_state		state;
