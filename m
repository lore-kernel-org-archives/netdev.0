From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] iproute2: Document the -D and -I options
Date: Mon, 11 Mar 2013 14:59:37 -0700
Message-ID: <87r4jliomu.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Larry Baker <baker@usgs.gov>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:57110 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754132Ab3CKV7o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 17:59:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


While looking into a sysctl regression in decnet on old kernels I
discovered this omission in the iproute2 documentation.

I can't imagine anyone's muscle memory remembering the longer forms.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 ip/ip.c       |    1 +
 man/man8/ip.8 |   10 ++++++++++
 2 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/ip/ip.c b/ip/ip.c
index c3ff627..e10ddb2 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -48,6 +48,7 @@ static void usage(void)
 "                   netns | l2tp | tcp_metrics }\n"
 "       OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails] | -r[esolve] |\n"
 "                    -f[amily] { inet | inet6 | ipx | dnet | bridge | link } |\n"
+"                    -4 | -6 | -I | -D | -B | -0 |\n"
 "                    -l[oops] { maximum-addr-flush-attempts } |\n"
 "                    -o[neline] | -t[imestamp] | -b[atch] [filename] |\n"
 "                    -rc[vbuf] [size]}\n");
diff --git a/man/man8/ip.8 b/man/man8/ip.8
index 881e1ff..37f9988 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -82,6 +82,16 @@ shortcut for
 .BR "\-family bridge" .
 
 .TP
+.B \-D
+shortcut for
+.BR "\-family decnet" .
+
+.TP
+.B \-I
+shortcut for
+.BR "\-family ipx" .
+
+.TP
 .B \-0
 shortcut for
 .BR "\-family link" .
-- 
1.7.5.4
