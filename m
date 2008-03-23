From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: [PATCH 4/5] [IPROUTE2] CBQ remember to doc usage of overhead
	parameter.
Date: Sun, 23 Mar 2008 23:52:12 +0100
Message-ID: <1206312732.15884.37.camel@localhost.localdomain>
References: <1206312248.15884.26.camel@localhost.localdomain>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-server.lanfw.cxnet.dk ([87.72.215.201]:48134 "EHLO
	comxexch02.comx.local" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756301AbYCWXAg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Mar 2008 19:00:36 -0400
In-Reply-To: <1206312248.15884.26.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


CBQ remember to doc usage of overhead parameter.

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---
 tc/q_cbq.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/tc/q_cbq.c b/tc/q_cbq.c
index c891ac5..e53d167 100644
--- a/tc/q_cbq.c
+++ b/tc/q_cbq.c
@@ -32,6 +32,7 @@ static void explain_class(void)
 	fprintf(stderr, "               [ prio NUMBER ] [ cell BYTES ] [ ewma LOG ]\n");
 	fprintf(stderr, "               [ estimator INTERVAL TIME_CONSTANT ]\n");
 	fprintf(stderr, "               [ split CLASSID ] [ defmap MASK/CHANGE ]\n");
+	fprintf(stderr, "               [ overhead BYTES ]\n");
 }
 
 static void explain(void)
-- 
1.5.3


