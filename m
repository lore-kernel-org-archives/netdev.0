From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] /proc/net/stat/rt_cache has a wrong header
Date: Fri, 18 Mar 2005 13:05:44 +0100
Message-ID: <423AC418.6080903@cosmosbay.com>
References: <4238C388.5040303@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040405040806040602080706"
To: acme@conectiva.com.br, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
In-Reply-To: <4238C388.5040303@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040405040806040602080706
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hello

The header of /proc/net/stat/rt_cache misses the 'in_slow_mc' field.
This patch adds it.

Thank you

Eric Dumazet


--------------040405040806040602080706
Content-Type: text/plain;
 name="diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="diff"

--- linux-2.6.11/net/ipv4/route.c	2005-03-17 11:19:45.000000000 +0100
+++ linux-2.6.11-ed2/net/ipv4/route.c	2005-03-18 13:01:11.000000000 +0100
@@ -393,7 +393,7 @@
 	struct rt_cache_stat *st = v;
 
 	if (v == SEQ_START_TOKEN) {
-		seq_printf(seq, "entries  in_hit in_slow_tot in_no_route in_brd in_martian_dst in_martian_src  out_hit out_slow_tot out_slow_mc  gc_total gc_ignored gc_goal_miss gc_dst_overflow in_hlist_search out_hlist_search\n");
+		seq_printf(seq, "entries  in_hit in_slow_tot in_slow_mc in_no_route in_brd in_martian_dst in_martian_src  out_hit out_slow_tot out_slow_mc  gc_total gc_ignored gc_goal_miss gc_dst_overflow in_hlist_search out_hlist_search\n");
 		return 0;
 	}
 	

--------------040405040806040602080706--
