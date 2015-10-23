From: Phil Sutter <phil@nwl.cc>
Subject: [iproute RFC PATCH 1/9] tc: add a man page for basic filter
Date: Fri, 23 Oct 2015 19:47:08 +0200
Message-ID: <1445622436-6386-2-git-send-email-phil@nwl.cc>
References: <1445622436-6386-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:46392 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932276AbbJWRrT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2015 13:47:19 -0400
In-Reply-To: <1445622436-6386-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/tc-basic.8 | 34 ++++++++++++++++++++++++++++++++++
 1 file changed, 34 insertions(+)
 create mode 100644 man/man8/tc-basic.8

diff --git a/man/man8/tc-basic.8 b/man/man8/tc-basic.8
new file mode 100644
index 0000000..fb39eaa
--- /dev/null
+++ b/man/man8/tc-basic.8
@@ -0,0 +1,34 @@
+.TH "Basic classifier in tc" 8 "21 Oct 2015" "iproute2" "Linux"
+
+.SH NAME
+basic \- basic traffic control filter
+.SH SYNOPSIS
+.in +8
+.ti -8
+.BR tc " " filter " ... " basic " [ " match
+.IR EMATCH_TREE " ] [ "
+.B action
+.IR ACTION_SPEC " ] [ "
+.B classid
+.IR CLASSID " ]"
+.SH DESCRIPTION
+The
+.B basic
+filter allows to classify packets using the extended match infrastructure.
+.SH OPTIONS
+.TP
+.BI action " ACTION_SPEC"
+Apply an action from the generic actions framework on matching packets.
+.TP
+.BI classid " CLASSID"
+Push matching packets into the class identified by
+.IR CLASSID .
+.TP
+.BI match " EMATCH_TREE"
+Match packets using the extended match infrastructure. See
+.BR tc-ematch (8)
+for a detailed description of the allowed syntax in
+.IR EMATCH_TREE .
+.SH SEE ALSO
+.BR tc (8),
+.BR tc-ematch (8)
-- 
2.1.2
