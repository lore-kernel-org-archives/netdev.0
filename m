From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Subject: [PATCH 2/2] [TCP]: Renove the __ prefix on the struct tcp_sock members
Date: Tue, 28 Nov 2006 01:16:50 -0200
Message-ID: <20061128031649.GD4029@mandriva.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.mandriva.com ([212.85.150.183]:25798 "EHLO mx1.mandriva.com")
	by vger.kernel.org with ESMTP id S935001AbWK1DQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Nov 2006 22:16:57 -0500
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As this struct is not userland visible at all.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 include/linux/tcp.h |  156 ++++++++++++++++++++++++++-------------------------
 1 files changed, 78 insertions(+), 78 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index b42ff0e..3cc70d1 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -185,17 +185,17 @@ struct tcp_sack_block_wire {
 };
 
 struct tcp_sack_block {
-	__u32	start_seq;
-	__u32	end_seq;
+	u32	start_seq;
+	u32	end_seq;
 };
 
 struct tcp_options_received {
 /*	PAWS/RTTM data	*/
 	long	ts_recent_stamp;/* Time we stored ts_recent (for aging) */
-	__u32	ts_recent;	/* Time stamp to echo next		*/
-	__u32	rcv_tsval;	/* Time stamp value             	*/
-	__u32	rcv_tsecr;	/* Time stamp echo reply        	*/
-	__u16 	saw_tstamp : 1,	/* Saw TIMESTAMP on last packet		*/
+	u32	ts_recent;	/* Time stamp to echo next		*/
+	u32	rcv_tsval;	/* Time stamp value             	*/
+	u32	rcv_tsecr;	/* Time stamp echo reply        	*/
+	u16 	saw_tstamp : 1,	/* Saw TIMESTAMP on last packet		*/
 		tstamp_ok : 1,	/* TIMESTAMP seen on SYN packet		*/
 		dsack : 1,	/* D-SACK is scheduled			*/
 		wscale_ok : 1,	/* Wscale seen on SYN packet		*/
@@ -203,10 +203,10 @@ struct tcp_options_received {
 		snd_wscale : 4,	/* Window scaling received from sender	*/
 		rcv_wscale : 4;	/* Window scaling to send to receiver	*/
 /*	SACKs data	*/
-	__u8	eff_sacks;	/* Size of SACK array to send with next packet */
-	__u8	num_sacks;	/* Number of SACK blocks		*/
-	__u16	user_mss;  	/* mss requested by user in ioctl */
-	__u16	mss_clamp;	/* Maximal mss, negotiated at connection setup */
+	u8	eff_sacks;	/* Size of SACK array to send with next packet */
+	u8	num_sacks;	/* Number of SACK blocks		*/
+	u16	user_mss;  	/* mss requested by user in ioctl */
+	u16	mss_clamp;	/* Maximal mss, negotiated at connection setup */
 };
 
 struct tcp_request_sock {
@@ -215,8 +215,8 @@ #ifdef CONFIG_TCP_MD5SIG
 	/* Only used by TCP MD5 Signature so far. */
 	struct tcp_request_sock_ops	*af_specific;
 #endif
-	__u32			 	rcv_isn;
-	__u32			 	snt_isn;
+	u32			 	rcv_isn;
+	u32			 	snt_isn;
 };
 
 static inline struct tcp_request_sock *tcp_rsk(const struct request_sock *req)
@@ -241,13 +241,13 @@ struct tcp_sock {
  *	read the code and the spec side by side (and laugh ...)
  *	See RFC793 and RFC1122. The RFC writes these in capitals.
  */
- 	__u32	rcv_nxt;	/* What we want to receive next 	*/
- 	__u32	snd_nxt;	/* Next sequence we send		*/
+ 	u32	rcv_nxt;	/* What we want to receive next 	*/
+ 	u32	snd_nxt;	/* Next sequence we send		*/
 
- 	__u32	snd_una;	/* First byte we want an ack for	*/
- 	__u32	snd_sml;	/* Last byte of the most recently transmitted small packet */
-	__u32	rcv_tstamp;	/* timestamp of last received ACK (for keepalives) */
-	__u32	lsndtime;	/* timestamp of last sent data packet (for restart window) */
+ 	u32	snd_una;	/* First byte we want an ack for	*/
+ 	u32	snd_sml;	/* Last byte of the most recently transmitted small packet */
+	u32	rcv_tstamp;	/* timestamp of last received ACK (for keepalives) */
+	u32	lsndtime;	/* timestamp of last sent data packet (for restart window) */
 
 	/* Data for direct copy to user */
 	struct {
@@ -265,30 +265,30 @@ #ifdef CONFIG_NET_DMA
 #endif
 	} ucopy;
 
-	__u32	snd_wl1;	/* Sequence for window update		*/
-	__u32	snd_wnd;	/* The window we expect to receive	*/
-	__u32	max_window;	/* Maximal window ever seen from peer	*/
-	__u32	mss_cache;	/* Cached effective mss, not including SACKS */
+	u32	snd_wl1;	/* Sequence for window update		*/
+	u32	snd_wnd;	/* The window we expect to receive	*/
+	u32	max_window;	/* Maximal window ever seen from peer	*/
+	u32	mss_cache;	/* Cached effective mss, not including SACKS */
 
-	__u32	window_clamp;	/* Maximal window to advertise		*/
-	__u32	rcv_ssthresh;	/* Current window clamp			*/
+	u32	window_clamp;	/* Maximal window to advertise		*/
+	u32	rcv_ssthresh;	/* Current window clamp			*/
 
-	__u32	frto_highmark;	/* snd_nxt when RTO occurred */
-	__u8	reordering;	/* Packet reordering metric.		*/
-	__u8	frto_counter;	/* Number of new acks after RTO */
-	__u8	nonagle;	/* Disable Nagle algorithm?             */
-	__u8	keepalive_probes; /* num of allowed keep alive probes	*/
+	u32	frto_highmark;	/* snd_nxt when RTO occurred */
+	u8	reordering;	/* Packet reordering metric.		*/
+	u8	frto_counter;	/* Number of new acks after RTO */
+	u8	nonagle;	/* Disable Nagle algorithm?             */
+	u8	keepalive_probes; /* num of allowed keep alive probes	*/
 
 /* RTT measurement */
-	__u32	srtt;		/* smoothed round trip time << 3	*/
-	__u32	mdev;		/* medium deviation			*/
-	__u32	mdev_max;	/* maximal mdev for the last rtt period	*/
-	__u32	rttvar;		/* smoothed mdev_max			*/
-	__u32	rtt_seq;	/* sequence number to update rttvar	*/
-
-	__u32	packets_out;	/* Packets which are "in flight"	*/
-	__u32	left_out;	/* Packets which leaved network	*/
-	__u32	retrans_out;	/* Retransmitted packets out		*/
+	u32	srtt;		/* smoothed round trip time << 3	*/
+	u32	mdev;		/* medium deviation			*/
+	u32	mdev_max;	/* maximal mdev for the last rtt period	*/
+	u32	rttvar;		/* smoothed mdev_max			*/
+	u32	rtt_seq;	/* sequence number to update rttvar	*/
+
+	u32	packets_out;	/* Packets which are "in flight"	*/
+	u32	left_out;	/* Packets which leaved network	*/
+	u32	retrans_out;	/* Retransmitted packets out		*/
 /*
  *      Options received (usually on last packet, some only on SYN packets).
  */
@@ -297,20 +297,20 @@ #endif
 /*
  *	Slow start and congestion control (see also Nagle, and Karn & Partridge)
  */
- 	__u32	snd_ssthresh;	/* Slow start size threshold		*/
- 	__u32	snd_cwnd;	/* Sending congestion window		*/
- 	__u16	snd_cwnd_cnt;	/* Linear increase counter		*/
-	__u16	snd_cwnd_clamp; /* Do not allow snd_cwnd to grow above this */
-	__u32	snd_cwnd_used;
-	__u32	snd_cwnd_stamp;
+ 	u32	snd_ssthresh;	/* Slow start size threshold		*/
+ 	u32	snd_cwnd;	/* Sending congestion window		*/
+ 	u16	snd_cwnd_cnt;	/* Linear increase counter		*/
+	u16	snd_cwnd_clamp; /* Do not allow snd_cwnd to grow above this */
+	u32	snd_cwnd_used;
+	u32	snd_cwnd_stamp;
 
 	struct sk_buff_head	out_of_order_queue; /* Out of order segments go here */
 
- 	__u32	rcv_wnd;	/* Current receiver window		*/
-	__u32	rcv_wup;	/* rcv_nxt on last window update sent	*/
-	__u32	write_seq;	/* Tail(+1) of data held in tcp send buffer */
-	__u32	pushed_seq;	/* Last pushed seq, required to talk to windows */
-	__u32	copied_seq;	/* Head of yet unread data		*/
+ 	u32	rcv_wnd;	/* Current receiver window		*/
+	u32	rcv_wup;	/* rcv_nxt on last window update sent	*/
+	u32	write_seq;	/* Tail(+1) of data held in tcp send buffer */
+	u32	pushed_seq;	/* Last pushed seq, required to talk to windows */
+	u32	copied_seq;	/* Head of yet unread data		*/
 
 /*	SACKs data	*/
 	struct tcp_sack_block duplicate_sack[1]; /* D-SACK block */
@@ -331,26 +331,26 @@ #endif
 	int     retransmit_cnt_hint;
 	int     forward_cnt_hint;
 
-	__u16	advmss;		/* Advertised MSS			*/
-	__u16	prior_ssthresh; /* ssthresh saved at recovery start	*/
-	__u32	lost_out;	/* Lost packets			*/
-	__u32	sacked_out;	/* SACK'd packets			*/
-	__u32	fackets_out;	/* FACK'd packets			*/
-	__u32	high_seq;	/* snd_nxt at onset of congestion	*/
+	u16	advmss;		/* Advertised MSS			*/
+	u16	prior_ssthresh; /* ssthresh saved at recovery start	*/
+	u32	lost_out;	/* Lost packets			*/
+	u32	sacked_out;	/* SACK'd packets			*/
+	u32	fackets_out;	/* FACK'd packets			*/
+	u32	high_seq;	/* snd_nxt at onset of congestion	*/
 
-	__u32	retrans_stamp;	/* Timestamp of the last retransmit,
+	u32	retrans_stamp;	/* Timestamp of the last retransmit,
 				 * also used in SYN-SENT to remember stamp of
 				 * the first SYN. */
-	__u32	undo_marker;	/* tracking retrans started here. */
+	u32	undo_marker;	/* tracking retrans started here. */
 	int	undo_retrans;	/* number of undoable retransmissions. */
-	__u32	urg_seq;	/* Seq of received urgent pointer */
-	__u16	urg_data;	/* Saved octet of OOB data and control flags */
-	__u8	urg_mode;	/* In urgent mode		*/
-	__u8	ecn_flags;	/* ECN status bits.			*/
-	__u32	snd_up;		/* Urgent pointer		*/
+	u32	urg_seq;	/* Seq of received urgent pointer */
+	u16	urg_data;	/* Saved octet of OOB data and control flags */
+	u8	urg_mode;	/* In urgent mode		*/
+	u8	ecn_flags;	/* ECN status bits.			*/
+	u32	snd_up;		/* Urgent pointer		*/
 
-	__u32	total_retrans;	/* Total retransmits for entire connection */
-	__u32	bytes_acked;	/* Appropriate Byte Counting - RFC3465 */
+	u32	total_retrans;	/* Total retransmits for entire connection */
+	u32	bytes_acked;	/* Appropriate Byte Counting - RFC3465 */
 
 	unsigned int		keepalive_time;	  /* time before keep alive takes place */
 	unsigned int		keepalive_intvl;  /* time interval between keep alive probes */
@@ -358,26 +358,26 @@ #endif
 
 	unsigned long last_synq_overflow; 
 
-	__u32	tso_deferred;
+	u32	tso_deferred;
 
 /* Receiver side RTT estimation */
 	struct {
-		__u32	rtt;
-		__u32	seq;
-		__u32	time;
+		u32	rtt;
+		u32	seq;
+		u32	time;
 	} rcv_rtt_est;
 
 /* Receiver queue space */
 	struct {
 		int	space;
-		__u32	seq;
-		__u32	time;
+		u32	seq;
+		u32	time;
 	} rcvq_space;
 
 /* TCP-specific MTU probe information. */
 	struct {
-		__u32		  probe_seq_start;
-		__u32		  probe_seq_end;
+		u32		  probe_seq_start;
+		u32		  probe_seq_end;
 	} mtu_probe;
 
 #ifdef CONFIG_TCP_MD5SIG
@@ -396,14 +396,14 @@ static inline struct tcp_sock *tcp_sk(co
 
 struct tcp_timewait_sock {
 	struct inet_timewait_sock tw_sk;
-	__u32			  tw_rcv_nxt;
-	__u32			  tw_snd_nxt;
-	__u32			  tw_rcv_wnd;
-	__u32			  tw_ts_recent;
+	u32			  tw_rcv_nxt;
+	u32			  tw_snd_nxt;
+	u32			  tw_rcv_wnd;
+	u32			  tw_ts_recent;
 	long			  tw_ts_recent_stamp;
 #ifdef CONFIG_TCP_MD5SIG
-	__u16			  tw_md5_keylen;
-	__u8			  tw_md5_key[TCP_MD5SIG_MAXKEYLEN];
+	u16			  tw_md5_keylen;
+	u8			  tw_md5_key[TCP_MD5SIG_MAXKEYLEN];
 #endif
 };
 
-- 
1.4.2.1.g3d5c

