From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 03/14] pktgen: mark read-only/mostly variables
Date: Thu, 27 Aug 2009 16:55:09 -0700
Message-ID: <20090827235705.337641584@vyatta.com>
References: <20090827235506.624381734@vyatta.com>
Cc: netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
To: David Miller <davem@davemloft.net>,
	Robert Olsson <robert.olsson@its.uu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58760 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752742AbZH0X7a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Aug 2009 19:59:30 -0400
Content-Disposition: inline; filename=pktgen-ro.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 net/core/pktgen.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

--- a/net/core/pktgen.c	2009-08-27 11:30:11.932524803 -0700
+++ b/net/core/pktgen.c	2009-08-27 11:57:12.299687034 -0700
@@ -414,7 +414,7 @@ static __u64 getCurUs(void)
 
 /* old include end */
 
-static char version[] __initdata = VERSION;
+static const char version[] __initconst = VERSION;
 
 static int pktgen_remove_device(struct pktgen_thread *t, struct pktgen_dev *i);
 static int pktgen_add_device(struct pktgen_thread *t, const char *ifname);
@@ -432,10 +432,10 @@ static unsigned int scan_ip6(const char 
 static unsigned int fmt_ip6(char *s, const char ip[16]);
 
 /* Module parameters, defaults. */
-static int pg_count_d = 1000;	/* 1000 pkts by default */
-static int pg_delay_d;
-static int pg_clone_skb_d;
-static int debug;
+static int pg_count_d __read_mostly = 1000;
+static int pg_delay_d __read_mostly;
+static int pg_clone_skb_d  __read_mostly;
+static int debug  __read_mostly;
 
 static DEFINE_MUTEX(pktgen_thread_lock);
 static LIST_HEAD(pktgen_threads);

-- 

