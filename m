From: Roman Mashak <mrv@mojatatu.com>
Subject: [PATCH iproute2 1/1] tc: fixed man page fonts for keywords and variable values
Date: Sun, 18 Dec 2016 12:25:12 -0500
Message-ID: <1482081912-30991-1-git-send-email-mrv@mojatatu.com>
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, daniel@iogearbox.net,
        xiyou.wangcong@gmail.com, Roman Mashak <mrv@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:36348 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753253AbcLRRZa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Dec 2016 12:25:30 -0500
Received: by mail-it0-f66.google.com with SMTP id n68so8054799itn.3
        for <netdev@vger.kernel.org>; Sun, 18 Dec 2016 09:25:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Roman Mashak <mrv@mojatatu.com>
---
 man/man8/tc.8 | 36 ++++++++++++++++++------------------
 1 file changed, 18 insertions(+), 18 deletions(-)

diff --git a/man/man8/tc.8 b/man/man8/tc.8
index 8a47a2b..583b72f 100644
--- a/man/man8/tc.8
+++ b/man/man8/tc.8
@@ -5,58 +5,58 @@ tc \- show / manipulate traffic control settings
 .B tc
 .RI "[ " OPTIONS " ]"
 .B qdisc [ add | change | replace | link | delete ] dev
-DEV
+\fIDEV\fR
 .B
 [ parent
-qdisc-id
+\fIqdisc-id\fR
 .B | root ]
 .B [ handle
-qdisc-id ] qdisc
+\fIqdisc-id\fR ] qdisc
 [ qdisc specific parameters ]
 .P
 
 .B tc
 .RI "[ " OPTIONS " ]"
 .B class [ add | change | replace | delete ] dev
-DEV
+\fIDEV\fR
 .B parent
-qdisc-id
+\fIqdisc-id\fR
 .B [ classid
-class-id ] qdisc
+\fIclass-id\fR ] qdisc
 [ qdisc specific parameters ]
 .P
 
 .B tc
 .RI "[ " OPTIONS " ]"
 .B filter [ add | change | replace | delete | get ] dev
-DEV
+\fIDEV\fR
 .B [ parent
-qdisc-id
+\fIqdisc-id\fR
 .B | root ] protocol
-protocol
+\fIprotocol\fR
 .B prio
-priority filtertype
+\fIpriority\fR filtertype
 [ filtertype specific parameters ]
 .B flowid
-flow-id
+\fIflow-id\fR
 
 .B tc
 .RI "[ " OPTIONS " ]"
 .RI "[ " FORMAT " ]"
 .B qdisc show [ dev
-DEV
+\fIDEV\fR
 .B ]
 .P
 .B tc
 .RI "[ " OPTIONS " ]"
 .RI "[ " FORMAT " ]"
 .B class show dev
-DEV
+\fIDEV\fR
 .P
 .B tc
 .RI "[ " OPTIONS " ]"
 .B filter show dev
-DEV
+\fIDEV\fR
 
 .P
 .ti 8
@@ -294,14 +294,14 @@ In the absence of classful qdiscs, classless qdiscs can only be attached at
 the root of a device. Full syntax:
 .P
 .B tc qdisc add dev
-DEV
+\fIDEV\fR
 .B root
 QDISC QDISC-PARAMETERS
 
 To remove, issue
 .P
 .B tc qdisc del dev
-DEV
+\fIDEV\fR
 .B root
 
 The
@@ -386,7 +386,7 @@ Type of Service
 Some qdiscs have built in rules for classifying packets based on the TOS field.
 .TP
 skb->priority
-Userspace programs can encode a class-id in the 'skb->priority' field using
+Userspace programs can encode a \fIclass-id\fR in the 'skb->priority' field using
 the SO_PRIORITY option.
 .P
 Each node within the tree can have its own filters but higher level filters
@@ -554,7 +554,7 @@ must be passed, either by passing its ID or by attaching directly to the root of
 When creating a qdisc or a filter, it can be named with the
 .B handle
 parameter. A class is named with the
-.B classid
+.B \fBclassid\fR
 parameter.
 
 .TP
-- 
1.9.1
