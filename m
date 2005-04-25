From: Olaf Rempel <razzor@kopf-tisch.de>
Subject: Re: [2.6.11 PATCH] /proc/net/stat/* cleanup
Date: Mon, 25 Apr 2005 19:00:48 +0200
Message-ID: <20050425190048.370dfd15@coruscant.lan>
References: <20050304203751.379dc6a6@coruscant>
	<20050424193007.0a687ef4.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="Multipart_Mon__25_Apr_2005_19_00_48_+0200_=OKRuDBXVXRIBrjH"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
In-Reply-To: <20050424193007.0a687ef4.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--Multipart_Mon__25_Apr_2005_19_00_48_+0200_=OKRuDBXVXRIBrjH
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Sun, 24 Apr 2005 19:30:07 -0700
"David S. Miller" <davem@davemloft.net> wrote:

> Your patch is mangled by your email client, the tabs have been turned
> into spaces, so the patch will not apply.
> 
> Also, please supply a proper "Signed-off-by:" line with your changes.

Whoops. OK

Patch against 2.6.11 vanilla

/proc/net/stat/* header cleanup

Signed-off-by: Olaf Rempel <razzor@kopf-tisch.de>


--Multipart_Mon__25_Apr_2005_19_00_48_+0200_=OKRuDBXVXRIBrjH
Content-Type: text/x-patch; name=linux-2.6.11-net-stats.patch
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=linux-2.6.11-net-stats.patch

--- linux-2.6.11/net/core/neighbour.c.org	2005-03-02 08:37:47.000000000 +0100
+++ linux-2.6.11/net/core/neighbour.c	2005-04-25 17:52:35.000000000 +0200
@@ -1948,7 +1948,7 @@
 	struct neigh_statistics *st = v;
 
 	if (v == SEQ_START_TOKEN) {
-		seq_printf(seq, "entries  allocs destroys hash_grows  lookups hits  res_failed  rcv_probes_mcast rcv_probes_ucast  periodic_gc_runs forced_gc_runs forced_gc_goal_miss\n");
+		seq_printf(seq, "entries  allocs destroys hash_grows  lookups hits  res_failed  rcv_probes_mcast rcv_probes_ucast  periodic_gc_runs forced_gc_runs\n");
 		return 0;
 	}
 
--- linux-2.6.11/net/ipv4/route.c.org	2005-03-02 08:38:38.000000000 +0100
+++ linux-2.6.11/net/ipv4/route.c	2005-04-25 17:55:20.000000000 +0200
@@ -393,7 +393,7 @@
 	struct rt_cache_stat *st = v;
 
 	if (v == SEQ_START_TOKEN) {
-		seq_printf(seq, "entries  in_hit in_slow_tot in_no_route in_brd in_martian_dst in_martian_src  out_hit out_slow_tot out_slow_mc  gc_total gc_ignored gc_goal_miss gc_dst_overflow in_hlist_search out_hlist_search\n");
+		seq_printf(seq, "entries  in_hit in_slow_tot in_slow_mc in_no_route in_brd in_martian_dst in_martian_src  out_hit out_slow_tot out_slow_mc  gc_total gc_ignored gc_goal_miss gc_dst_overflow in_hlist_search out_hlist_search\n");
 		return 0;
 	}
 	

--Multipart_Mon__25_Apr_2005_19_00_48_+0200_=OKRuDBXVXRIBrjH--
