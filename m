From: Randy Dunlap <rdunlap@xenotime.net>
Subject: [PATCH] sunrpc: fix rpcb_clnt.c kernel-doc notation
Date: Tue, 17 Apr 2012 17:03:56 -0700
Message-ID: <4F8E04EC.30405@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from oproxy9.bluehost.com ([69.89.24.6]:43495 "HELO
	oproxy9.bluehost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753673Ab2DRADT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 20:03:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <rdunlap@xenotime.net>

Fix kernel-doc warnings in sunrpc/rpcb_clnt.c:

Warning(net/sunrpc/rpcb_clnt.c:428): No description found for parameter 'net'
Warning(net/sunrpc/rpcb_clnt.c:567): No description found for parameter 'net'

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
---
 net/sunrpc/rpcb_clnt.c |    2 ++
 1 file changed, 2 insertions(+)

--- lnx-34-rc3.orig/net/sunrpc/rpcb_clnt.c
+++ lnx-34-rc3/net/sunrpc/rpcb_clnt.c
@@ -394,6 +394,7 @@ static int rpcb_register_call(struct rpc
 
 /**
  * rpcb_register - set or unset a port registration with the local rpcbind svc
+ * @net: target network namespace
  * @prog: RPC program number to bind
  * @vers: RPC version number to bind
  * @prot: transport protocol to register
@@ -521,6 +522,7 @@ static int rpcb_unregister_all_protofami
 
 /**
  * rpcb_v4_register - set or unset a port registration with the local rpcbind
+ * @net: target network namespace
  * @program: RPC program number of service to (un)register
  * @version: RPC version number of service to (un)register
  * @address: address family, IP address, and port to (un)register
