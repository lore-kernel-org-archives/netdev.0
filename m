From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] common code for generating tcp_info
Date: Mon, 7 Jun 2004 09:16:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040607091608.07924826@dell_ss3.pdx.osdl.net>
References: <20040604153749.5d8a13b9@dell_ss3.pdx.osdl.net>
	<1086619698.4113.22.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Joe Perches <joe@perches.com>, David S Miller <davem@redhat.com>
In-Reply-To: <1086619698.4113.22.camel@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The comment was out of date, keep moving, nothing to see here...

diff -Nru a/include/linux/tcp.h b/include/linux/tcp.h
--- a/include/linux/tcp.h	2004-06-07 09:15:59 -07:00
+++ b/include/linux/tcp.h	2004-06-07 09:15:59 -07:00
@@ -351,11 +351,11 @@
 	__u8	urg_mode;	/* In urgent mode		*/
 	__u32	snd_up;		/* Urgent pointer		*/
 
-	/* The syn_wait_lock is necessary only to avoid tcp_get_info having
+	/* The syn_wait_lock is necessary only to avoid proc interface having
 	 * to grab the main lock sock while browsing the listening hash
 	 * (otherwise it's deadlock prone).
-	 * This lock is acquired in read mode only from tcp_get_info() and
-	 * it's acquired in write mode _only_ from code that is actively
+	 * This lock is acquired in read mode only from listening_get_next()
+	 * and it's acquired in write mode _only_ from code that is actively
 	 * changing the syn_wait_queue. All readers that are holding
 	 * the master sock lock don't need to grab this lock in read mode
 	 * too as the syn_wait_queue writes are always protected from
