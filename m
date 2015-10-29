From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 2/4] genl: add manpage
Date: Thu, 29 Oct 2015 10:55:22 +0100
Message-ID: <1446112524-6986-3-git-send-email-phil@nwl.cc>
References: <1446112524-6986-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:52910 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755485AbbJ2Jz0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2015 05:55:26 -0400
In-Reply-To: <1446112524-6986-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 man/man8/genl.8 | 77 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 77 insertions(+)
 create mode 100644 man/man8/genl.8

diff --git a/man/man8/genl.8 b/man/man8/genl.8
new file mode 100644
index 0000000..22e44a8
--- /dev/null
+++ b/man/man8/genl.8
@@ -0,0 +1,77 @@
+.TH GENL 8 "29 Oct 2015" "iproute2" "Linux"
+.SH NAME
+genl \- generic netlink utility frontend
+.SH SYNOPSIS
+.in +8
+.ti -8
+.BR genl " [ " -s [ tatistics "] ] [ " -d [ etails "] ] [ " -r [ aw "] ] " OBJECT
+
+.ti -8
+.BR genl " { " -V [ ersion "] | " -h [ elp "] }"
+
+.ti -8
+.IR OBJECT " := { "
+.B ctrl
+.IR CTRL_OPTS " }"
+
+.ti -8
+.IR CTRL_OPTS " := { "
+.BR help " | " list " | " monitor " | " get
+.IR PARMS " }"
+
+.ti -8
+.IR PARMS " := { "
+.B name
+.IR NAME " | "
+.B id
+.IR ID " }"
+.SH DESCRIPTION
+The
+.B genl
+utility provides a simple frontend to the generic netlink library. Although it's
+designed to support multiple
+.IR OBJECT s,
+for now only the
+.B ctrl
+object is available, which is used to query the generic netlink controller.
+.SS ctrl
+The generic netlink controller can be queried in various ways:
+.TP
+.B help
+This command just prints a help text for the
+.B ctrl
+object.
+.TP
+.B list
+Show the registered netlink users.
+.TP
+.B monitor
+Listen for generic netlink notifications.
+.TP
+.B get
+Query the controller for a given user, identified either by
+.BR name " or " id .
+.SH OPTIONS
+genl supports the following options.
+.TP
+.B \-h, \-help
+Show summary of options.
+.TP
+.B \-V, \-Version
+Show version of program.
+.TP
+.B \-s, \-stats, \-statistics
+Show object statistics.
+.TP
+.B \-d, \-details
+Show object details.
+.TP
+.B \-r, \-raw
+Dump raw output only.
+.SH SEE ALSO
+.BR ip (8)
+.br
+.SH AUTHOR
+genl was written by Jamal Hadi Salim <hadi@cyberus.ca>.
+.PP
+This manual page was written by Petr Sabata <contyk@redhat.com>.
-- 
2.1.2
