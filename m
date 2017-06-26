From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH iproute2 5/5] rdma: Add initial manual for the tool
Date: Mon, 26 Jun 2017 21:21:28 +0300
Message-ID: <20170626182128.24964-6-leon@kernel.org>
References: <20170626182128.24964-1-leon@kernel.org>
Cc: Leon Romanovsky <leonro@mellanox.com>,
        Doug Ledford <dledford@redhat.com>,
        Ariel Almog <ariela@mellanox.com>,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Linux RDMA <linux-rdma@vger.kernel.org>,
        Linux Netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:44070 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751393AbdFZSWQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 26 Jun 2017 14:22:16 -0400
In-Reply-To: <20170626182128.24964-1-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
---
 man/man8/rdma.8 | 82 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 82 insertions(+)
 create mode 100644 man/man8/rdma.8

diff --git a/man/man8/rdma.8 b/man/man8/rdma.8
new file mode 100644
index 00000000..7578c15e
--- /dev/null
+++ b/man/man8/rdma.8
@@ -0,0 +1,82 @@
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
+\fB\-V\fR[\fIersion\fR] }
+
+.SH OPTIONS
+
+.TP
+.BR "\-V" , " -Version"
+Print the version of the
+.B rdma
+tool and exit.
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
+.SH REPORTING BUGS
+Report any bugs to the Linux RDMA mailing list
+.B <linux-rdma@vger.kernel.org>
+where the development and maintenance is primarily done.
+You do not have to be subscribed to the list to send a message there.
+
+.SH AUTHOR
+Leon Romanovsky <leonro@mellanox.com>
