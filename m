From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH v6 iproute2 8/8] rdma: Add initial manual for the tool
Date: Sun, 20 Aug 2017 12:58:28 +0300
Message-ID: <20170820095828.13812-9-leon@kernel.org>
References: <20170820095828.13812-1-leon@kernel.org>
Cc: linux-rdma@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Ariel Almog <ariela@mellanox.com>,
        David Laight <David.Laight@ACULAB.COM>,
        Linux Netdev <netdev@vger.kernel.org>
To: Doug Ledford <dledford@redhat.com>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:49270 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752572AbdHTJ6y (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 20 Aug 2017 05:58:54 -0400
In-Reply-To: <20170820095828.13812-1-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
---
 man/man8/rdma-dev.8  |  55 +++++++++++++++++++++++++++
 man/man8/rdma-link.8 |  55 +++++++++++++++++++++++++++
 man/man8/rdma.8      | 102 +++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 212 insertions(+)
 create mode 100644 man/man8/rdma-dev.8
 create mode 100644 man/man8/rdma-link.8
 create mode 100644 man/man8/rdma.8

diff --git a/man/man8/rdma-dev.8 b/man/man8/rdma-dev.8
new file mode 100644
index 00000000..461681b6
--- /dev/null
+++ b/man/man8/rdma-dev.8
@@ -0,0 +1,55 @@
+.TH RDMA\-DEV 8 "06 Jul 2017" "iproute2" "Linux"
+.SH NAME
+rdmak-dev \- RDMA device configuration
+.SH SYNOPSIS
+.sp
+.ad l
+.in +8
+.ti -8
+.B rdma
+.RI "[ " OPTIONS " ]"
+.B dev
+.RI  " { " COMMAND " | "
+.BR help " }"
+.sp
+
+.ti -8
+.IR OPTIONS " := { "
+\fB\-V\fR[\fIersion\fR] |
+\fB\-d\fR[\fIetails\fR] }
+
+.ti -8
+.B rdma dev show
+.RI "[ " DEV " ]"
+
+.ti -8
+.B rdma dev help
+
+.SH "DESCRIPTION"
+.SS rdma dev show - display rdma device attributes
+
+.PP
+.I "DEV"
+- specifies the RDMA device to show.
+If this argument is omitted all devices are listed.
+
+.SH "EXAMPLES"
+.PP
+rdma dev
+.RS 4
+Shows the state of all RDMA devices on the system.
+.RE
+.PP
+rdma dev show mlx5_3
+.RS 4
+Shows the state of specified RDMA device.
+.RE
+.PP
+
+.SH SEE ALSO
+.BR rdma (8),
+.BR rdma-link (8),
+.br
+
+.SH AUTHOR
+Leon Romanovsky <leonro@mellanox.com>
diff --git a/man/man8/rdma-link.8 b/man/man8/rdma-link.8
new file mode 100644
index 00000000..8ed049ef
--- /dev/null
+++ b/man/man8/rdma-link.8
@@ -0,0 +1,55 @@
+.TH RDMA\-LINK 8 "06 Jul 2017" "iproute2" "Linux"
+.SH NAME
+rdma-link \- rdma link configuration
+.SH SYNOPSIS
+.sp
+.ad l
+.in +8
+.ti -8
+.B devlink
+.RI "[ " OPTIONS " ]"
+.B link
+.RI  " { " COMMAND " | "
+.BR help " }"
+.sp
+
+.ti -8
+.IR OPTIONS " := { "
+\fB\-V\fR[\fIersion\fR] |
+\fB\-d\fR[\fIetails\fR] }
+
+.ti -8
+.B rdma link show
+.RI "[ " DEV/PORT_INDEX " ]"
+
+.ti -8
+.B rdma link help
+
+.SH "DESCRIPTION"
+.SS rdma link show - display rdma link attributes
+
+.PP
+.I "DEV/PORT_INDEX"
+- specifies the RDMa link to show.
+If this argument is omitted all links are listed.
+
+.SH "EXAMPLES"
+.PP
+rdma link show
+.RS 4
+Shows the state of all rdma links on the system.
+.RE
+.PP
+rdma link show mlx5_2/1
+.RS 4
+Shows the state of specified rdma link.
+.RE
+.PP
+
+.SH SEE ALSO
+.BR rdma (8),
+.BR rdma-dev (8),
+.br
+
+.SH AUTHOR
+Leon Romanovsky <leonro@mellanox.com>
diff --git a/man/man8/rdma.8 b/man/man8/rdma.8
new file mode 100644
index 00000000..798b33d3
--- /dev/null
+++ b/man/man8/rdma.8
@@ -0,0 +1,102 @@
+.TH RDMA 8 "28 Mar 2017" "iproute2" "Linux"
+.SH NAME
+rdma \- RDMA tool
+.SH SYNOPSIS
+.sp
+.ad l
+.in +8
+.ti -8
+.B rdma
+.RI "[ " OPTIONS " ] " OBJECT " { " COMMAND " | "
+.BR help " }"
+.sp
+
+.ti -8
+.IR OBJECT " := { "
+.BR dev " | " link " }"
+.sp
+
+.ti -8
+.IR OPTIONS " := { "
+\fB\-V\fR[\fIersion\fR] |
+\fB\-d\fR[\fIetails\fR] }
+\fB\-j\fR[\fIson\fR] }
+\fB\-p\fR[\fIretty\fR] }
+
+.SH OPTIONS
+
+.TP
+.BR "\-V" , " -Version"
+Print the version of the
+.B rdma
+tool and exit.
+
+.TP
+.BR "\-d" , " --details"
+Otuput detailed information.
+
+.TP
+.BR "\-p" , " --pretty"
+When combined with -j generate a pretty JSON output.
+
+.TP
+.BR "\-j" , " --json"
+Generate JSON output.
+
+.SS
+.I OBJECT
+
+.TP
+.B dev
+- RDMA device.
+
+.TP
+.B link
+- RDMA port related.
+
+.PP
+The names of all objects may be written in full or
+abbreviated form, for example
+.B stats
+can be abbreviated as
+.B stat
+or just
+.B s.
+
+.SS
+.I COMMAND
+
+Specifies the action to perform on the object.
+The set of possible actions depends on the object type.
+As a rule, it is possible to
+.B show
+(or
+.B list
+) objects, but some objects do not allow all of these operations
+or have some additional commands. The
+.B help
+command is available for all objects. It prints
+out a list of available commands and argument syntax conventions.
+.sp
+If no command is given, some default command is assumed.
+Usually it is
+.B list
+or, if the objects of this class cannot be listed,
+.BR "help" .
+
+.SH EXIT STATUS
+Exit status is 0 if command was successful or a positive integer upon failure.
+
+.SH SEE ALSO
+.BR rdma-dev (8),
+.BR rdma-link (8),
+.br
+
+.SH REPORTING BUGS
+Report any bugs to the Linux RDMA mailing list
+.B <linux-rdma@vger.kernel.org>
+where the development and maintenance is primarily done.
+You do not have to be subscribed to the list to send a message there.
+
+.SH AUTHOR
+Leon Romanovsky <leonro@mellanox.com>
-- 
2.14.1
