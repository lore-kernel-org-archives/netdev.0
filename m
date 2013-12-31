From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [PATCH 2/2] net, sch: fix the typo in register_qdisc()
Date: Wed,  1 Jan 2014 04:34:51 +0800
Message-ID: <1388522091-17536-2-git-send-email-zwu.kernel@gmail.com>
References: <1388522091-17536-1-git-send-email-zwu.kernel@gmail.com>
Cc: davem@davemloft.net, Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:60438 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756521Ab3LaUfI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 15:35:08 -0500
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <zwu.kernel@gmail.com>;
	Tue, 31 Dec 2013 13:35:07 -0700
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id A87361FF001A
	for <netdev@vger.kernel.org>; Tue, 31 Dec 2013 13:34:38 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp08025.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBVKZ6WF9961814
	for <netdev@vger.kernel.org>; Tue, 31 Dec 2013 21:35:06 +0100
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBVKZ5aD012898
	for <netdev@vger.kernel.org>; Tue, 31 Dec 2013 13:35:05 -0700
In-Reply-To: <1388522091-17536-1-git-send-email-zwu.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
---
 net/sched/sch_api.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index c31190e..1313145 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -135,7 +135,7 @@ static DEFINE_RWLOCK(qdisc_mod_lock);
 
 static struct Qdisc_ops *qdisc_base;
 
-/* Register/uregister queueing discipline */
+/* Register/unregister queueing discipline */
 
 int register_qdisc(struct Qdisc_ops *qops)
 {
-- 
1.7.6.5
