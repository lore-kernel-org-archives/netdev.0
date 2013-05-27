From: =?UTF-8?q?Petr=20=C5=A0abata?= <contyk@redhat.com>
Subject: [PATCH] iproute2: Add missing manpages for genl and ifstat
Date: Mon, 27 May 2013 22:13:17 +0200
Message-ID: <1369685597-13321-1-git-send-email-contyk@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?q?Petr=20=C5=A0abata?= <contyk@redhat.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37677 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757283Ab3E0UNY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 May 2013 16:13:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch provides simple manpages for genl and ifstat utilities.

Signed-off-by: Petr =C5=A0abata <contyk@redhat.com>
---
 man/man8/genl.8   | 36 +++++++++++++++++++++++++++++++++++
 man/man8/ifstat.8 | 57 +++++++++++++++++++++++++++++++++++++++++++++++=
++++++++
 2 files changed, 93 insertions(+)
 create mode 100644 man/man8/genl.8
 create mode 100644 man/man8/ifstat.8

diff --git a/man/man8/genl.8 b/man/man8/genl.8
new file mode 100644
index 0000000..d46818c
--- /dev/null
+++ b/man/man8/genl.8
@@ -0,0 +1,36 @@
+.TH GENL 8
+.SH NAME
+genl \- generic netlink utility frontend
+.SH SYNOPSIS
+.B genl
+.RI [ options ] { ctrl | etc } [ help ]
+.SH DESCRIPTION
+This manual page documents briefly the
+.B genl
+command.
+.PP
+\fBgenl\fP utility provides a simple frontend to the generic netlink l=
ibrary.
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
diff --git a/man/man8/ifstat.8 b/man/man8/ifstat.8
new file mode 100644
index 0000000..7042948
--- /dev/null
+++ b/man/man8/ifstat.8
@@ -0,0 +1,57 @@
+.TH IFSTAST 8
+.SH NAME
+ifstat \- handy utility to read net interface statistics
+.SH SYNOPSIS
+.B ifstat
+.RI [ options ]
+.RI [ interface
+.RI [ interface
+.RI [ ... ] ] ]
+.SH DESCRIPTION
+This manual page documents briefly the
+.B ifstat
+command.
+.PP
+\fBifstat\fP neatly prints out network interface statistics.
+The utility keeps records of the previous data displayed in history fi=
les and by default only shows difference between the last and the curre=
nt call.  Location of the history files defaults to /tmp/.ifstat.u$UID =
but may be overridden with the IFSTAT_HISTORY environment variable.
+.SH OPTIONS
+These programs follow the usual GNU command line syntax, with long
+options starting with two dashes (`-').
+ifstat supports the following options.
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
+.B \-d, \-\-scan=3DSECS
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
+.B \-t, \-\-interval=3DSECS
+Report average over the last SECS seconds.
+.TP
+.B \-z, \-\-zeros
+Show entries with zero activity.
+.SH SEE ALSO
+.BR ip (8)
+.br
+.SH AUTHOR
+ifstat was written by Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>.
+.PP
+This manual page was written by Petr Sabata <contyk@redhat.com>.
--=20
1.8.1.4
