From: Petr Sabata <contyk@redhat.com>
Subject: [PATCH 3/3] iproute2: arpd - fix usage and manpage options
Date: Thu,  6 Oct 2011 14:45:34 +0200
Message-ID: <1317905134-23175-4-git-send-email-contyk@redhat.com>
References: <1317905134-23175-1-git-send-email-contyk@redhat.com>
Cc: Petr Sabata <contyk@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58868 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758295Ab1JFMrk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Oct 2011 08:47:40 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p96ClepL024166
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 6 Oct 2011 08:47:40 -0400
In-Reply-To: <1317905134-23175-1-git-send-email-contyk@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Petr Sabata <contyk@redhat.com>
---
 man/man8/arpd.8 |    4 ++--
 misc/arpd.c     |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/man/man8/arpd.8 b/man/man8/arpd.8
index d172600..37b6ba4 100644
--- a/man/man8/arpd.8
+++ b/man/man8/arpd.8
@@ -4,7 +4,7 @@
 arpd \- userspace arp daemon.
 
 .SH SYNOPSIS
-Usage: arpd [ -lk ] [ -a N ] [ -b dbase ] [ -f file ] [ interfaces ]
+Usage: arpd [ -lkh? ] [ -a N ] [ -b dbase ] [ -B number ] [ -f file ] [ -n time ] [ -R rate ] [ interfaces ]
 
 .SH DESCRIPTION
 The
@@ -34,7 +34,7 @@ Suppress sending broadcast queries by kernel. It takes sense together with optio
 -n <TIME>
 Timeout of negative cache. When resolution fails arpd suppresses further attempts to resolve for this period. It makes sense only together with option -k This timeout should not be too much longer than boot time of a typical host not supporting gratuitous ARP. Default value is 60 seconds.
 .TP
--r <RATE>
+-R <RATE>
 Maximal steady rate of broadcasts sent by arpd in packets per second. Default value is 1.
 .TP
 -B <NUMBER>
diff --git a/misc/arpd.c b/misc/arpd.c
index 128c49d..124d3fb 100644
--- a/misc/arpd.c
+++ b/misc/arpd.c
@@ -94,7 +94,7 @@ int broadcast_burst = 3000;
 void usage(void)
 {
 	fprintf(stderr,
-"Usage: arpd [ -lk ] [ -a N ] [ -b dbase ] [ -f file ] [ interfaces ]\n");
+"Usage: arpd [ -lkh? ] [ -a N ] [ -b dbase ] [ -B number ] [ -f file ] [ -n time ] [ -R rate ] [ interfaces ]\n");
 	exit(1);
 }
 
-- 
1.7.6.4
