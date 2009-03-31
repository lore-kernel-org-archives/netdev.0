From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: Re: [PATCH v2 3/3] Doc: Fix spelling in RCU/rculist_nulls.txt.
Date: Tue, 31 Mar 2009 21:36:48 +0200
Message-ID: <1238528208.9018.1.camel@localhost.localdomain>
References: <20090330085302.19172.22808.stgit@localhost.localdomain>
	 <20090330090306.19172.94170.stgit@localhost.localdomain>
	 <49D0FA6E.4090402@gmail.com>
	 <Pine.LNX.4.64.0903302155550.13385@ask.diku.dk>
	 <Pine.LNX.4.64.0903302210030.13385@ask.diku.dk>
	 <20090331105400.GA6843@ff.dom.local>
	 <Pine.LNX.4.64.0903312042410.2950@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:39944 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753600AbZCaTgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 15:36:53 -0400
In-Reply-To: <Pine.LNX.4.64.0903312042410.2950@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Doc: Fix spelling in RCU/rculist_nulls.txt.

Trival spelling fixes in RCU/rculist_nulls.txt.

Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---

 Documentation/RCU/rculist_nulls.txt |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)


diff --git a/Documentation/RCU/rculist_nulls.txt b/Documentation/RCU/rculist_nulls.txt
index 239f542..6389dec 100644
--- a/Documentation/RCU/rculist_nulls.txt
+++ b/Documentation/RCU/rculist_nulls.txt
@@ -21,7 +21,7 @@ if (obj) {
   /*
    * Because a writer could delete object, and a writer could
    * reuse these object before the RCU grace period, we
-   * must check key after geting the reference on object
+   * must check key after getting the reference on object
    */
   if (obj->key != key) { // not the object we expected
      put_ref(obj);
@@ -117,7 +117,7 @@ a race (some writer did a delete and/or a move of an object
 to another chain) checking the final 'nulls' value if
 the lookup met the end of chain. If final 'nulls' value
 is not the slot number, then we must restart the lookup at
-the begining. If the object was moved to same chain,
+the beginning. If the object was moved to the same chain,
 then the reader doesnt care : It might eventually
 scan the list again without harm.
 


