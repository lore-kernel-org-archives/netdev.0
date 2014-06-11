From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] ceph: remove bogus extern
Date: Tue, 10 Jun 2014 20:30:13 -0700
Message-ID: <20140610203013.6a5e5904@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: Sage Weil <sage@inktank.com>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35123 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753833AbaFKDaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 23:30:17 -0400
Received: by mail-pa0-f51.google.com with SMTP id ey11so1405663pad.24
        for <netdev@vger.kernel.org>; Tue, 10 Jun 2014 20:30:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sparse complained about this bogus extern on definition of
a function.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/net/ceph/osd_client.c	2014-04-20 13:04:38.238240920 -0700
+++ b/net/ceph/osd_client.c	2014-06-10 20:21:51.894499623 -0700
@@ -2491,7 +2491,7 @@ EXPORT_SYMBOL(ceph_osdc_sync);
  * Call all pending notify callbacks - for use after a watch is
  * unregistered, to make sure no more callbacks for it will be invoked
  */
-extern void ceph_osdc_flush_notifies(struct ceph_osd_client *osdc)
+void ceph_osdc_flush_notifies(struct ceph_osd_client *osdc)
 {
 	flush_workqueue(osdc->notify_wq);
 }
