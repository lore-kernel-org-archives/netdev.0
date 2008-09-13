From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 1/2] skbedit: Fix a typo in the documentation
Date: Fri, 12 Sep 2008 17:45:47 -0700
Message-ID: <20080913004547.5342.9954.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jarkao2@gmail.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.171]:9799 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756027AbYIMApt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2008 20:45:49 -0400
Received: by wf-out-1314.google.com with SMTP id 27so1025680wfd.4
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2008 17:45:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Fix a typo in documentation

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 Documentation/networking/multiqueue.txt |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/Documentation/networking/multiqueue.txt b/Documentation/networking/multiqueue.txt
index 10113ff..8c2b06b 100644
--- a/Documentation/networking/multiqueue.txt
+++ b/Documentation/networking/multiqueue.txt
@@ -68,7 +68,7 @@ the default simple_tx_hash or a custom netdev->select_queue() defined.
 
 The behavior of tc filters remains the same.  However a new tc action,
 skbedit, has been added.  Assuming you wanted to route all traffic to a
-specific host, for example 192.168.0.3, though a specific queue you could use
+specific host, for example 192.168.0.3, through a specific queue you could use
 this action and establish a filter such as:
 
 tc filter add dev eth0 parent 1: protocol ip prio 1 u32 \

