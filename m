From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH] net: qdisc: enhance default_qdisc documentation
Date: Tue, 15 Sep 2015 10:33:07 +0200
Message-ID: <1442305987-6559-1-git-send-email-phil@nwl.cc>
Cc: davem@davemloft.net, cwang@twopensource.com,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:44483 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751330AbbIOIdJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2015 04:33:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Aside from some lingual cleanup, point out which interfaces are not or
partly covered by this setting.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 Documentation/sysctl/net.txt | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/Documentation/sysctl/net.txt b/Documentation/sysctl/net.txt
index 6294b51..809ab6e 100644
--- a/Documentation/sysctl/net.txt
+++ b/Documentation/sysctl/net.txt
@@ -54,13 +54,15 @@ default_qdisc
 --------------
 
 The default queuing discipline to use for network devices. This allows
-overriding the default queue discipline of pfifo_fast with an
-alternative. Since the default queuing discipline is created with the
-no additional parameters so is best suited to queuing disciplines that
-work well without configuration like stochastic fair queue (sfq),
-CoDel (codel) or fair queue CoDel (fq_codel). Don't use queuing disciplines
-like Hierarchical Token Bucket or Deficit Round Robin which require setting
-up classes and bandwidths.
+overriding the default of pfifo_fast with an alternative. Since the default
+queuing discipline is created without additional parameters so is best suited
+to queuing disciplines that work well without configuration like stochastic
+fair queue (sfq), CoDel (codel) or fair queue CoDel (fq_codel). Don't use
+queuing disciplines like Hierarchical Token Bucket or Deficit Round Robin
+which require setting up classes and bandwidths. Note that physical multiqueue
+interfaces still use mq as root qdisc, which in turn uses this default for its
+leaves. Virtual devices (like e.g. lo or veth) ignore this setting and instead
+default to noqueue.
 Default: pfifo_fast
 
 busy_read
-- 
2.1.2
