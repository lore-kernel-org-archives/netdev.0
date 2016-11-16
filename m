From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH iproute2] ifstat/nstat: fix help output alignment
Date: Tue, 15 Nov 2016 22:34:14 -0500
Message-ID: <20161116033414.24632-1-vapier@gentoo.org>
To: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:54836 "EHLO smtp.gentoo.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752020AbcKPDeU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 22:34:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some lines use tabs while others use spaces.  Use spaces everywhere.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 misc/ifstat.c | 24 ++++++++++++------------
 misc/nstat.c  | 22 +++++++++++-----------
 2 files changed, 23 insertions(+), 23 deletions(-)

diff --git a/misc/ifstat.c b/misc/ifstat.c
index d55197375e3c..92d67b0c5fd1 100644
--- a/misc/ifstat.c
+++ b/misc/ifstat.c
@@ -662,18 +662,18 @@ static void usage(void)
 {
 	fprintf(stderr,
 "Usage: ifstat [OPTION] [ PATTERN [ PATTERN ] ]\n"
-"   -h, --help		this message\n"
-"   -a, --ignore	ignore history\n"
-"   -d, --scan=SECS	sample every statistics every SECS\n"
-"   -e, --errors	show errors\n"
-"   -j, --json          format output in JSON\n"
-"   -n, --nooutput	do history only\n"
-"   -p, --pretty        pretty print\n"
-"   -r, --reset		reset history\n"
-"   -s, --noupdate	don\'t update history\n"
-"   -t, --interval=SECS	report average over the last SECS\n"
-"   -V, --version	output version information\n"
-"   -z, --zeros		show entries with zero activity\n");
+"   -h, --help           this message\n"
+"   -a, --ignore         ignore history\n"
+"   -d, --scan=SECS      sample every statistics every SECS\n"
+"   -e, --errors         show errors\n"
+"   -j, --json           format output in JSON\n"
+"   -n, --nooutput       do history only\n"
+"   -p, --pretty         pretty print\n"
+"   -r, --reset          reset history\n"
+"   -s, --noupdate       don't update history\n"
+"   -t, --interval=SECS  report average over the last SECS\n"
+"   -V, --version        output version information\n"
+"   -z, --zeros          show entries with zero activity\n");
 
 	exit(-1);
 }
diff --git a/misc/nstat.c b/misc/nstat.c
index 1cb6c7eea27a..1212b1f2c812 100644
--- a/misc/nstat.c
+++ b/misc/nstat.c
@@ -526,17 +526,17 @@ static void usage(void)
 {
 	fprintf(stderr,
 "Usage: nstat [OPTION] [ PATTERN [ PATTERN ] ]\n"
-"   -h, --help		this message\n"
-"   -a, --ignore	ignore history\n"
-"   -d, --scan=SECS	sample every statistics every SECS\n"
-"   -j, --json          format output in JSON\n"
-"   -n, --nooutput	do history only\n"
-"   -p, --pretty        pretty print\n"
-"   -r, --reset		reset history\n"
-"   -s, --noupdate	don\'t update history\n"
-"   -t, --interval=SECS	report average over the last SECS\n"
-"   -V, --version	output version information\n"
-"   -z, --zeros		show entries with zero activity\n");
+"   -h, --help           this message\n"
+"   -a, --ignore         ignore history\n"
+"   -d, --scan=SECS      sample every statistics every SECS\n"
+"   -j, --json           format output in JSON\n"
+"   -n, --nooutput       do history only\n"
+"   -p, --pretty         pretty print\n"
+"   -r, --reset          reset history\n"
+"   -s, --noupdate       don't update history\n"
+"   -t, --interval=SECS  report average over the last SECS\n"
+"   -V, --version        output version information\n"
+"   -z, --zeros          show entries with zero activity\n");
 	exit(-1);
 }
 
-- 
2.10.2
