From: Masatake YAMATO <yamato@redhat.com>
Subject: [PATCH 3/3] ss: add unix_seqpacket to the help message and the man page
Date: Wed,  8 Jan 2014 20:13:48 +0900
Message-ID: <1389179628-22147-3-git-send-email-yamato@redhat.com>
References: <1389179628-22147-1-git-send-email-yamato@redhat.com>
Cc: yamato@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62065 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755351AbaAHLON (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 06:14:13 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s08BEDIn008444
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 8 Jan 2014 06:14:13 -0500
In-Reply-To: <1389179628-22147-1-git-send-email-yamato@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Masatake YAMATO <yamato@redhat.com>
---
 man/man8/ss.8 | 2 +-
 misc/ss.c     | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/man/man8/ss.8 b/man/man8/ss.8
index e55dd0c..807d9dc 100644
--- a/man/man8/ss.8
+++ b/man/man8/ss.8
@@ -87,7 +87,7 @@ Currently the following families are supported: unix, inet, inet6, link, netlink
 .B \-A QUERY, \-\-query=QUERY, \-\-socket=QUERY
 List of socket tables to dump, separated by commas. The following identifiers
 are understood: all, inet, tcp, udp, raw, unix, packet, netlink, unix_dgram,
-unix_stream, packet_raw, packet_dgram.
+unix_stream, unix_seqpacket, packet_raw, packet_dgram.
 .TP
 .B \-D FILE, \-\-diag=FILE
 Do not display anything, just dump raw information about TCP sockets to FILE after applying filters. If FILE is - stdout is used.
diff --git a/misc/ss.c b/misc/ss.c
index cea3f2e..675f7c5 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -3072,7 +3072,7 @@ static void _usage(FILE *dest)
 "   -f, --family=FAMILY display sockets of type FAMILY\n"
 "\n"
 "   -A, --query=QUERY, --socket=QUERY\n"
-"       QUERY := {all|inet|tcp|udp|raw|unix|packet|netlink}[,QUERY]\n"
+"       QUERY := {all|inet|tcp|udp|raw|unix|unix_dgram|unix_stream|unix_seqpacket|packet|netlink}[,QUERY]\n"
 "\n"
 "   -D, --diag=FILE     Dump raw information about TCP sockets to FILE\n"
 "   -F, --filter=FILE   read filter information from FILE\n"
-- 
1.8.4.2
