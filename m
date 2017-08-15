From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH v4 iproute2 4/7] rdma: Add initial manual for the tool
Date: Tue, 15 Aug 2017 16:00:17 +0300
Message-ID: <20170815130020.29509-5-leonro@mellanox.com>
References: <20170815130020.29509-1-leonro@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Jiri Pirko <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170815130020.29509-1-leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
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
+Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
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
+Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
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
+.B <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
+where the development and maintenance is primarily done.
+You do not have to be subscribed to the list to send a message there.
+
+.SH AUTHOR
+Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
-- 
2.14.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
