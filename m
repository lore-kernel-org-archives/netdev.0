From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH iproute2 V2 4/4] rdma: Add initial manual for the tool
Date: Mon,  3 Jul 2017 17:06:58 +0300
Message-ID: <20170703140658.4091-5-leon@kernel.org>
References: <20170703140658.4091-1-leon@kernel.org>
Cc: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Linux RDMA <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170703140658.4091-1-leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Signed-off-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 man/man8/Makefile |  3 +-
 man/man8/rdma.8   | 82 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 84 insertions(+), 1 deletion(-)
 create mode 100644 man/man8/rdma.8

diff --git a/man/man8/Makefile b/man/man8/Makefile
index f3318644..81979a07 100644
--- a/man/man8/Makefile
+++ b/man/man8/Makefile
@@ -19,7 +19,8 @@ MAN8PAGES = $(TARGETS) ip.8 arpd.8 lnstat.8 routel.8 rtacct.8 rtmon.8 rtpr.8 ss.
 	tc-simple.8 tc-skbedit.8 tc-vlan.8 tc-xt.8 tc-skbmod.8 tc-ife.8 \
 	tc-tunnel_key.8 tc-sample.8 \
 	devlink.8 devlink-dev.8 devlink-monitor.8 devlink-port.8 devlink-sb.8 \
-	ifstat.8
+	ifstat.8 \
+	rdma.8
 
 all: $(TARGETS)
 
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
+.B <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
+where the development and maintenance is primarily done.
+You do not have to be subscribed to the list to send a message there.
+
+.SH AUTHOR
+Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
-- 
2.13.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
