From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] sched: fix act file names in header comment
Date: Wed,  5 Nov 2014 20:51:51 +0100
Message-ID: <1415217111-9803-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:57900 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751043AbaKETv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 14:51:56 -0500
Received: by mail-wi0-f181.google.com with SMTP id n3so3083181wiv.8
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2014 11:51:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: 4bba3925 ("[PKT_SCHED]: Prefix tc actions with act_")
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/sched/act_gact.c   | 2 +-
 net/sched/act_ipt.c    | 2 +-
 net/sched/act_mirred.c | 2 +-
 net/sched/act_pedit.c  | 2 +-
 net/sched/act_police.c | 2 +-
 net/sched/act_simple.c | 2 +-
 6 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index d6bcbd9..7fffc22 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -1,5 +1,5 @@
 /*
- * net/sched/gact.c	Generic actions
+ * net/sched/act_gact.c		Generic actions
  *
  *		This program is free software; you can redistribute it and/or
  *		modify it under the terms of the GNU General Public License
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index 8a64a07..cbc8dd7 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -1,5 +1,5 @@
 /*
- * net/sched/ipt.c     iptables target interface
+ * net/sched/act_ipt.c		iptables target interface
  *
  *TODO: Add other tables. For now we only support the ipv4 table targets
  *
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index eb48306..5953517 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -1,5 +1,5 @@
 /*
- * net/sched/mirred.c	packet mirroring and redirect actions
+ * net/sched/act_mirred.c	packet mirroring and redirect actions
  *
  *		This program is free software; you can redistribute it and/or
  *		modify it under the terms of the GNU General Public License
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index 5f9bcb2..59649d5 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -1,5 +1,5 @@
 /*
- * net/sched/pedit.c	Generic packet editor
+ * net/sched/act_pedit.c	Generic packet editor
  *
  *		This program is free software; you can redistribute it and/or
  *		modify it under the terms of the GNU General Public License
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 69791ca..9a1c42a 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -1,5 +1,5 @@
 /*
- * net/sched/police.c	Input police filter.
+ * net/sched/act_police.c	Input police filter
  *
  *		This program is free software; you can redistribute it and/or
  *		modify it under the terms of the GNU General Public License
diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index 992c231..6a8d948 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -1,5 +1,5 @@
 /*
- * net/sched/simp.c	Simple example of an action
+ * net/sched/act_simple.c	Simple example of an action
  *
  *		This program is free software; you can redistribute it and/or
  *		modify it under the terms of the GNU General Public License
-- 
1.9.3
