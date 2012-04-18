From: Randy Dunlap <rdunlap@xenotime.net>
Subject: [PATCH] sunrpc: fix rpc_pipe.c kernel-doc notation
Date: Tue, 17 Apr 2012 17:03:59 -0700
Message-ID: <4F8E04EF.7000707@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from oproxy7-pub.bluehost.com ([67.222.55.9]:50212 "HELO
	oproxy7-pub.bluehost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753651Ab2DRADW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 20:03:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <rdunlap@xenotime.net>

Fix kernel-doc warnings in sunrpc/rpc_pipe.c:

Warning(net/sunrpc/rpc_pipe.c:133): No description found for parameter 'pipe'
Warning(net/sunrpc/rpc_pipe.c:133): Excess function parameter 'inode' description in 'rpc_queue_upcall'
Warning(net/sunrpc/rpc_pipe.c:839): No description found for parameter 'pipe'
Warning(net/sunrpc/rpc_pipe.c:839): Excess function parameter 'ops' description in 'rpc_mkpipe_dentry'
Warning(net/sunrpc/rpc_pipe.c:839): Excess function parameter 'flags' description in 'rpc_mkpipe_dentry'
Warning(net/sunrpc/rpc_pipe.c:949): No description found for parameter 'dentry'
Warning(net/sunrpc/rpc_pipe.c:949): Excess function parameter 'clnt' description in 'rpc_remove_client_dir'

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
---
 net/sunrpc/rpc_pipe.c |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

--- lnx-34-rc3.orig/net/sunrpc/rpc_pipe.c
+++ lnx-34-rc3/net/sunrpc/rpc_pipe.c
@@ -120,7 +120,7 @@ EXPORT_SYMBOL_GPL(rpc_pipe_generic_upcal
 
 /**
  * rpc_queue_upcall - queue an upcall message to userspace
- * @inode: inode of upcall pipe on which to queue given message
+ * @pipe: upcall pipe on which to queue given message
  * @msg: message to queue
  *
  * Call with an @inode created by rpc_mkpipe() to queue an upcall.
@@ -819,9 +819,7 @@ static int rpc_rmdir_depopulate(struct d
  * @parent: dentry of directory to create new "pipe" in
  * @name: name of pipe
  * @private: private data to associate with the pipe, for the caller's use
- * @ops: operations defining the behavior of the pipe: upcall, downcall,
- *	release_pipe, open_pipe, and destroy_msg.
- * @flags: rpc_pipe flags
+ * @pipe: &rpc_pipe containing input parameters
  *
  * Data is made available for userspace to read by calls to
  * rpc_queue_upcall().  The actual reads will result in calls to
@@ -943,7 +941,7 @@ struct dentry *rpc_create_client_dir(str
 
 /**
  * rpc_remove_client_dir - Remove a directory created with rpc_create_client_dir()
- * @clnt: rpc client
+ * @dentry: dentry for the pipe
  */
 int rpc_remove_client_dir(struct dentry *dentry)
 {
