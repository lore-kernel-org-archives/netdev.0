From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: [PATCH v2 3/3] Doc: Fix spelling in RCU/rculist_nulls.txt.
Date: Mon, 30 Mar 2009 22:11:47 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0903302210030.13385@ask.diku.dk>
References: <20090330085302.19172.22808.stgit@localhost.localdomain>
 <20090330090306.19172.94170.stgit@localhost.localdomain> <49D0FA6E.4090402@gmail.com>
 <Pine.LNX.4.64.0903302155550.13385@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jesper Dangaard Brouer <hawk@comx.dk>,
	"David S. Miller" <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:42113 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758068AbZC3ULy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Mar 2009 16:11:54 -0400
In-Reply-To: <Pine.LNX.4.64.0903302155550.13385@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Trival spelling fixes in RCU/rculist_nulls.txt.

Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Reviewed-by: Jarek Poplawski <jarkao2@gmail.com>
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

