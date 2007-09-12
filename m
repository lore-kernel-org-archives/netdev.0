From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] [IPROUTE2] Basic documentation for dynamic link creation/destruction.
Date: Wed, 12 Sep 2007 07:03:32 -0600
Message-ID: <m1myvsavdn.fsf_-_@ebiederm.dsl.xmission.com>
References: <m14pi0cac5.fsf@ebiederm.dsl.xmission.com>
	<m1zlzsavla.fsf@ebiederm.dsl.xmission.com>
	<m1veagavjr.fsf_-_@ebiederm.dsl.xmission.com>
	<m1r6l4avhp.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, Pavel Emelyanov <xemul@openvz.org>,
	Patrick McHardy <kaber@trash.net>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:48577 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818AbXILNEF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 09:04:05 -0400
In-Reply-To: <m1r6l4avhp.fsf_-_@ebiederm.dsl.xmission.com> (Eric
	W. Biederman's message of "Wed, 12 Sep 2007 07:01:06 -0600")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This updates the usage to indicate that we have support link creation
and destruction in addition to just setting link parameters.

It's not really great documentation of the new netlink support
for link creations and removal but it is a start.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 ip/iplink.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index 64989b2..541f3d6 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -38,7 +38,8 @@ static void usage(void) __attribute__((noreturn));
 
 void iplink_usage(void)
 {
-	fprintf(stderr, "Usage: ip link set DEVICE { up | down |\n");
+	fprintf(stderr, "Usage: ip link { set | add | replace | delete } DEVICE {\n");
+	fprintf(stderr, "			     up | down |\n");
 	fprintf(stderr, "	                     arp { on | off } |\n");
 	fprintf(stderr, "	                     dynamic { on | off } |\n");
 	fprintf(stderr, "	                     multicast { on | off } |\n");
@@ -48,7 +49,9 @@ void iplink_usage(void)
 	fprintf(stderr, "	                     txqueuelen PACKETS |\n");
 	fprintf(stderr, "	                     name NEWNAME |\n");
 	fprintf(stderr, "	                     address LLADDR | broadcast LLADDR |\n");
-	fprintf(stderr, "	                     mtu MTU }\n");
+	fprintf(stderr, "	                     mtu MTU | \n");
+	fprintf(stderr, "			     type TYPE [ TYPE specifc options]\n");
+	fprintf(stderr, "			     }\n");
 	fprintf(stderr, "       ip link show [ DEVICE ]\n");
 	exit(-1);
 }
-- 
1.5.3.rc6.17.g1911

