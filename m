From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] sched classifier: make cgroup table local
Date: Tue, 31 Dec 2013 11:55:29 -0800
Message-ID: <20131231115529.5d70c393@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:48320 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753829Ab3LaTzh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 14:55:37 -0500
Received: by mail-pd0-f171.google.com with SMTP id z10so12619561pdj.16
        for <netdev@vger.kernel.org>; Tue, 31 Dec 2013 11:55:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Doesn't need to be global.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/net/sched/cls_cgroup.c	2013-12-30 21:34:18.370981874 -0800
+++ b/net/sched/cls_cgroup.c	2013-12-30 21:34:51.982552390 -0800
@@ -103,7 +103,7 @@ static struct cftype ss_files[] = {
 	{ }	/* terminate */
 };
 
-struct cgroup_subsys net_cls_subsys = {
+static struct cgroup_subsys net_cls_subsys = {
 	.name		= "net_cls",
 	.css_alloc	= cgrp_css_alloc,
 	.css_online	= cgrp_css_online,
