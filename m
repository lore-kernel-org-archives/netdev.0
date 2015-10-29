From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 3/4] ifstat: add manpage
Date: Thu, 29 Oct 2015 10:55:23 +0100
Message-ID: <1446112524-6986-4-git-send-email-phil@nwl.cc>
References: <1446112524-6986-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:52874 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755493AbbJ2Jz0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2015 05:55:26 -0400
In-Reply-To: <1446112524-6986-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 man/man8/ifstat.8 | 59 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 59 insertions(+)
 create mode 100644 man/man8/ifstat.8

diff --git a/man/man8/ifstat.8 b/man/man8/ifstat.8
new file mode 100644
index 0000000..e49d868
--- /dev/null
+++ b/man/man8/ifstat.8
@@ -0,0 +1,59 @@
+.TH IFSTAT 8 "28 Oct 2015" "iproute2" "Linux"
+.SH NAME
+ifstat \- handy utility to read network interface statistics
+.SH SYNOPSIS
+.in +8
+.ti -8
+.BR ifstat " [ "
+.IR OPTIONS " ] [ " INTERFACE_LIST " ]"
+
+.ti -8
+.IR INTERFACE_LIST " := " INTERFACE_LIST " | " interface
+.SH DESCRIPTION
+\fBifstat\fP neatly prints out network interface statistics.
+The utility keeps records of the previous data displayed in history files and
+by default only shows difference between the last and the current call.
+Location of the history files defaults to /tmp/.ifstat.u$UID but may be
+overridden with the IFSTAT_HISTORY environment variable.
+.SH OPTIONS
+.TP
+.B \-h, \-\-help
+Show summary of options.
+.TP
+.B \-V, \-\-version
+Show version of program.
+.TP
+.B \-a, \-\-ignore
+Ignore the history file.
+.TP
+.B \-d, \-\-scan=SECS
+Sample statistics every SECS second.
+.TP
+.B \-e, \-\-errors
+Show errors.
+.TP
+.B \-n, \-\-nooutput
+Don't display any output.  Update the history file only.
+.TP
+.B \-r, \-\-reset
+Reset history.
+.TP
+.B \-s, \-\-noupdate
+Don't update the history file.
+.TP
+.B \-t, \-\-interval=SECS
+Report average over the last SECS seconds.
+.TP
+.B \-z, \-\-zeros
+Show entries with zero activity.
+.SH ENVIRONMENT
+.TP
+.B IFSTAT_HISTORY
+If set, it's value is interpreted as alternate history file path.
+.SH SEE ALSO
+.BR ip (8)
+.br
+.SH AUTHOR
+ifstat was written by Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>.
+.PP
+This manual page was written by Petr Sabata <contyk@redhat.com>.
-- 
2.1.2
