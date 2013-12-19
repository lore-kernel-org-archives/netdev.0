From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next 1/5] sctp: fix checkpatch errors with space required or prohibited
Date: Thu, 19 Dec 2013 14:51:58 +0800
Message-ID: <1387435922-24152-2-git-send-email-wangweidong1@huawei.com>
References: <1387435922-24152-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-sctp@vger.kernel.org>
To: <davem@davemloft.net>, <vyasevich@gmail.com>,
	<nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:22386 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751227Ab3LSGxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 01:53:19 -0500
In-Reply-To: <1387435922-24152-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix checkpatch errors while the space is required or prohibited
to the "=,()++..."

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/sctp/auth.c          |  6 +++---
 net/sctp/chunk.c         |  4 ++--
 net/sctp/input.c         |  4 ++--
 net/sctp/ipv6.c          |  2 +-
 net/sctp/outqueue.c      |  8 ++++----
 net/sctp/sm_make_chunk.c |  4 ++--
 net/sctp/sm_sideeffect.c |  4 ++--
 net/sctp/sm_statefuns.c  | 20 ++++++++++----------
 net/sctp/socket.c        | 30 +++++++++++++++---------------
 net/sctp/ulpqueue.c      |  4 ++--
 10 files changed, 43 insertions(+), 43 deletions(-)

diff --git a/net/sctp/auth.c b/net/sctp/auth.c
index 5c9f64c..78767aa 100644
--- a/net/sctp/auth.c
+++ b/net/sctp/auth.c
@@ -41,7 +41,7 @@ static struct sctp_hmac sctp_hmac_list[SCTP_AUTH_NUM_HMACS] = {
 	},
 	{
 		.hmac_id = SCTP_AUTH_HMAC_ID_SHA1,
-		.hmac_name="hmac(sha1)",
+		.hmac_name = "hmac(sha1)",
 		.hmac_len = SCTP_SHA1_SIG_SIZE,
 	},
 	{
@@ -51,7 +51,7 @@ static struct sctp_hmac sctp_hmac_list[SCTP_AUTH_NUM_HMACS] = {
 #if defined (CONFIG_CRYPTO_SHA256) || defined (CONFIG_CRYPTO_SHA256_MODULE)
 	{
 		.hmac_id = SCTP_AUTH_HMAC_ID_SHA256,
-		.hmac_name="hmac(sha256)",
+		.hmac_name = "hmac(sha256)",
 		.hmac_len = SCTP_SHA256_SIG_SIZE,
 	}
 #endif
@@ -163,7 +163,7 @@ static int sctp_auth_compare_vectors(struct sctp_auth_bytes *vector1,
 		 * lead-zero padded.  If it is not, it
 		 * is automatically larger numerically.
 		 */
-		for (i = 0; i < abs(diff); i++ ) {
+		for (i = 0; i < abs(diff); i++) {
 			if (longer[i] != 0)
 				return diff;
 		}
diff --git a/net/sctp/chunk.c b/net/sctp/chunk.c
index 5573e42..158701d 100644
--- a/net/sctp/chunk.c
+++ b/net/sctp/chunk.c
@@ -254,7 +254,7 @@ struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *asoc,
 		SCTP_INC_STATS_USER(sock_net(asoc->base.sk), SCTP_MIB_FRAGUSRMSGS);
 
 	/* Create chunks for all the full sized DATA chunks. */
-	for (i=0, len=first_len; i < whole; i++) {
+	for (i = 0, len = first_len; i < whole; i++) {
 		frag = SCTP_DATA_MIDDLE_FRAG;
 
 		if (0 == i)
@@ -317,7 +317,7 @@ struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *asoc,
 			goto errout;
 		}
 
-		err = sctp_user_addto_chunk(chunk, offset, over,msgh->msg_iov);
+		err = sctp_user_addto_chunk(chunk, offset, over, msgh->msg_iov);
 
 		/* Put the chunk->skb back into the form expected by send.  */
 		__skb_pull(chunk->skb, (__u8 *)chunk->chunk_hdr
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 042ec6c..726a474 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -119,7 +119,7 @@ int sctp_rcv(struct sk_buff *skb)
 	struct sctp_af *af;
 	struct net *net = dev_net(skb->dev);
 
-	if (skb->pkt_type!=PACKET_HOST)
+	if (skb->pkt_type != PACKET_HOST)
 		goto discard_it;
 
 	SCTP_INC_STATS_BH(net, SCTP_MIB_INSCTPPACKS);
@@ -1058,7 +1058,7 @@ static struct sctp_association *__sctp_rcv_walk_lookup(struct net *net,
 		if (ch_end > skb_tail_pointer(skb))
 			break;
 
-		switch(ch->type) {
+		switch (ch->type) {
 		    case SCTP_CID_AUTH:
 			    have_auth = chunk_num;
 			    break;
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 32db816..24388d1 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -401,7 +401,7 @@ static void sctp_v6_copy_addrlist(struct list_head *addrlist,
 }
 
 /* Initialize a sockaddr_storage from in incoming skb. */
-static void sctp_v6_from_skb(union sctp_addr *addr,struct sk_buff *skb,
+static void sctp_v6_from_skb(union sctp_addr *addr, struct sk_buff *skb,
 			     int is_saddr)
 {
 	__be16 *port;
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index b6b09f3..111516c 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -110,7 +110,7 @@ static inline int sctp_cacc_skip_3_1_d(struct sctp_transport *primary,
 				       struct sctp_transport *transport,
 				       int count_of_newacks)
 {
-	if (count_of_newacks >=2 && transport != primary)
+	if (count_of_newacks >= 2 && transport != primary)
 		return 1;
 	return 0;
 }
@@ -470,7 +470,7 @@ void sctp_retransmit(struct sctp_outq *q, struct sctp_transport *transport,
 	struct net *net = sock_net(q->asoc->base.sk);
 	int error = 0;
 
-	switch(reason) {
+	switch (reason) {
 	case SCTP_RTXR_T3_RTX:
 		SCTP_INC_STATS(net, SCTP_MIB_T3_RETRANSMITS);
 		sctp_transport_lower_cwnd(transport, SCTP_LOWER_CWND_T3_RTX);
@@ -1088,7 +1088,7 @@ sctp_flush_out:
 	 *
 	 * --xguo
 	 */
-	while ((ltransport = sctp_list_dequeue(&transport_list)) != NULL ) {
+	while ((ltransport = sctp_list_dequeue(&transport_list)) != NULL) {
 		struct sctp_transport *t = list_entry(ltransport,
 						      struct sctp_transport,
 						      send_ready);
@@ -1217,7 +1217,7 @@ int sctp_outq_sack(struct sctp_outq *q, struct sctp_chunk *chunk)
 		 * destinations for which cacc_saw_newack is set.
 		 */
 		if (transport->cacc.cacc_saw_newack)
-			count_of_newacks ++;
+			count_of_newacks++;
 	}
 
 	/* Move the Cumulative TSN Ack Point if appropriate.  */
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index d9aaf96..439d872 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -2308,7 +2308,7 @@ int sctp_process_init(struct sctp_association *asoc, struct sctp_chunk *chunk,
 	 * added as the primary transport.  The source address seems to
 	 * be a a better choice than any of the embedded addresses.
 	 */
-	if(!sctp_assoc_add_peer(asoc, peer_addr, gfp, SCTP_ACTIVE))
+	if (!sctp_assoc_add_peer(asoc, peer_addr, gfp, SCTP_ACTIVE))
 		goto nomem;
 
 	if (sctp_cmp_addr_exact(sctp_source(chunk), peer_addr))
@@ -3334,7 +3334,7 @@ static __be16 sctp_get_asconf_response(struct sctp_chunk *asconf_ack,
 
 	while (asconf_ack_len > 0) {
 		if (asconf_ack_param->crr_id == asconf_param->crr_id) {
-			switch(asconf_ack_param->param_hdr.type) {
+			switch (asconf_ack_param->param_hdr.type) {
 			case SCTP_PARAM_SUCCESS_REPORT:
 				return SCTP_ERROR_NO_ERROR;
 			case SCTP_PARAM_ERR_CAUSE:
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 02b7ad1..89bfa67 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -404,7 +404,7 @@ void sctp_generate_proto_unreach_event(unsigned long data)
 	struct sctp_transport *transport = (struct sctp_transport *) data;
 	struct sctp_association *asoc = transport->asoc;
 	struct net *net = sock_net(asoc->base.sk);
-	
+
 	sctp_bh_lock_sock(asoc->base.sk);
 	if (sock_owned_by_user(asoc->base.sk)) {
 		pr_debug("%s: sock is busy\n", __func__);
@@ -543,7 +543,7 @@ static void sctp_cmd_init_failed(sctp_cmd_seq_t *commands,
 {
 	struct sctp_ulpevent *event;
 
-	event = sctp_ulpevent_make_assoc_change(asoc,0, SCTP_CANT_STR_ASSOC,
+	event = sctp_ulpevent_make_assoc_change(asoc, 0, SCTP_CANT_STR_ASSOC,
 						(__u16)error, 0, 0, NULL,
 						GFP_ATOMIC);
 
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index ee02771..bc690b4 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -2945,7 +2945,7 @@ sctp_disposition_t sctp_sf_eat_data_6_2(struct net *net,
 		return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
 						  commands);
 
-	error = sctp_eat_data(asoc, chunk, commands );
+	error = sctp_eat_data(asoc, chunk, commands);
 	switch (error) {
 	case SCTP_IERROR_NO_ERROR:
 		break;
@@ -3066,7 +3066,7 @@ sctp_disposition_t sctp_sf_eat_data_fast_4_4(struct net *net,
 		return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
 						  commands);
 
-	error = sctp_eat_data(asoc, chunk, commands );
+	error = sctp_eat_data(asoc, chunk, commands);
 	switch (error) {
 	case SCTP_IERROR_NO_ERROR:
 	case SCTP_IERROR_HIGH_TSN:
@@ -3765,7 +3765,7 @@ sctp_disposition_t sctp_sf_do_asconf_ack(struct net *net,
 		 */
 		sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_STOP,
 				SCTP_TO(SCTP_EVENT_TIMEOUT_T4_RTO));
-		sctp_add_cmd_sf(commands, SCTP_CMD_DISCARD_PACKET,SCTP_NULL());
+		sctp_add_cmd_sf(commands, SCTP_CMD_DISCARD_PACKET, SCTP_NULL());
 		sctp_add_cmd_sf(commands, SCTP_CMD_SET_SK_ERR,
 				SCTP_ERROR(ECONNABORTED));
 		sctp_add_cmd_sf(commands, SCTP_CMD_ASSOC_FAILED,
@@ -3799,7 +3799,7 @@ sctp_disposition_t sctp_sf_do_asconf_ack(struct net *net,
 		/* We are going to ABORT, so we might as well stop
 		 * processing the rest of the chunks in the packet.
 		 */
-		sctp_add_cmd_sf(commands, SCTP_CMD_DISCARD_PACKET,SCTP_NULL());
+		sctp_add_cmd_sf(commands, SCTP_CMD_DISCARD_PACKET, SCTP_NULL());
 		sctp_add_cmd_sf(commands, SCTP_CMD_SET_SK_ERR,
 				SCTP_ERROR(ECONNABORTED));
 		sctp_add_cmd_sf(commands, SCTP_CMD_ASSOC_FAILED,
@@ -4451,7 +4451,7 @@ static sctp_disposition_t sctp_sf_violation_chunklen(
 				     void *arg,
 				     sctp_cmd_seq_t *commands)
 {
-	static const char err_str[]="The following chunk had invalid length:";
+	static const char err_str[] = "The following chunk had invalid length:";
 
 	return sctp_sf_abort_violation(net, ep, asoc, arg, commands, err_str,
 					sizeof(err_str));
@@ -4514,7 +4514,7 @@ static sctp_disposition_t sctp_sf_violation_ctsn(
 				     void *arg,
 				     sctp_cmd_seq_t *commands)
 {
-	static const char err_str[]="The cumulative tsn ack beyond the max tsn currently sent:";
+	static const char err_str[] = "The cumulative tsn ack beyond the max tsn currently sent:";
 
 	return sctp_sf_abort_violation(net, ep, asoc, arg, commands, err_str,
 					sizeof(err_str));
@@ -4534,7 +4534,7 @@ static sctp_disposition_t sctp_sf_violation_chunk(
 				     void *arg,
 				     sctp_cmd_seq_t *commands)
 {
-	static const char err_str[]="The following chunk violates protocol:";
+	static const char err_str[] = "The following chunk violates protocol:";
 
 	if (!asoc)
 		return sctp_sf_violation(net, ep, asoc, type, arg, commands);
@@ -6000,7 +6000,7 @@ static struct sctp_packet *sctp_ootb_pkt_new(struct net *net,
 		/* Special case the INIT-ACK as there is no peer's vtag
 		 * yet.
 		 */
-		switch(chunk->chunk_hdr->type) {
+		switch (chunk->chunk_hdr->type) {
 		case SCTP_CID_INIT_ACK:
 		{
 			sctp_initack_chunk_t *initack;
@@ -6017,7 +6017,7 @@ static struct sctp_packet *sctp_ootb_pkt_new(struct net *net,
 		/* Special case the INIT and stale COOKIE_ECHO as there is no
 		 * vtag yet.
 		 */
-		switch(chunk->chunk_hdr->type) {
+		switch (chunk->chunk_hdr->type) {
 		case SCTP_CID_INIT:
 		{
 			sctp_init_chunk_t *init;
@@ -6231,7 +6231,7 @@ static int sctp_eat_data(const struct sctp_association *asoc,
 		/* We are going to ABORT, so we might as well stop
 		 * processing the rest of the chunks in the packet.
 		 */
-		sctp_add_cmd_sf(commands, SCTP_CMD_DISCARD_PACKET,SCTP_NULL());
+		sctp_add_cmd_sf(commands, SCTP_CMD_DISCARD_PACKET, SCTP_NULL());
 		sctp_add_cmd_sf(commands, SCTP_CMD_SET_SK_ERR,
 				SCTP_ERROR(ECONNABORTED));
 		sctp_add_cmd_sf(commands, SCTP_CMD_ASSOC_FAILED,
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index d39fd0c..500972a 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -1568,7 +1568,7 @@ static int sctp_sendmsg(struct kiocb *iocb, struct sock *sk,
 	struct net *net = sock_net(sk);
 	struct sctp_sock *sp;
 	struct sctp_endpoint *ep;
-	struct sctp_association *new_asoc=NULL, *asoc=NULL;
+	struct sctp_association *new_asoc = NULL, *asoc = NULL;
 	struct sctp_transport *transport, *chunk_tp;
 	struct sctp_chunk *chunk;
 	union sctp_addr to;
@@ -2462,7 +2462,7 @@ static int sctp_setsockopt_peer_addr_params(struct sock *sk,
 	int hb_change, pmtud_change, sackdelay_change;
 
 	if (optlen != sizeof(struct sctp_paddrparams))
-		return - EINVAL;
+		return -EINVAL;
 
 	if (copy_from_user(&params, optval, optlen))
 		return -EFAULT;
@@ -2483,7 +2483,7 @@ static int sctp_setsockopt_peer_addr_params(struct sock *sk,
 	/* If an address other than INADDR_ANY is specified, and
 	 * no transport is found, then the request is invalid.
 	 */
-	if (!sctp_is_any(sk, ( union sctp_addr *)&params.spp_address)) {
+	if (!sctp_is_any(sk, (union sctp_addr *)&params.spp_address)) {
 		trans = sctp_addr_id2transport(sk, &params.spp_address,
 					       params.spp_assoc_id);
 		if (!trans)
@@ -2588,7 +2588,7 @@ static int sctp_setsockopt_delayed_ack(struct sock *sk,
 		else
 			params.sack_freq = 0;
 	} else
-		return - EINVAL;
+		return -EINVAL;
 
 	/* Validate value parameter. */
 	if (params.sack_delay > 500)
@@ -3332,7 +3332,7 @@ static int sctp_setsockopt_hmac_ident(struct sock *sk,
 	if (optlen < sizeof(struct sctp_hmacalgo))
 		return -EINVAL;
 
-	hmacs= memdup_user(optval, optlen);
+	hmacs = memdup_user(optval, optlen);
 	if (IS_ERR(hmacs))
 		return PTR_ERR(hmacs);
 
@@ -3370,7 +3370,7 @@ static int sctp_setsockopt_auth_key(struct sock *sk,
 	if (optlen <= sizeof(struct sctp_authkey))
 		return -EINVAL;
 
-	authkey= memdup_user(optval, optlen);
+	authkey = memdup_user(optval, optlen);
 	if (IS_ERR(authkey))
 		return PTR_ERR(authkey);
 
@@ -4467,7 +4467,7 @@ static int sctp_getsockopt_peer_addr_params(struct sock *sk, int len,
 	/* If an address other than INADDR_ANY is specified, and
 	 * no transport is found, then the request is invalid.
 	 */
-	if (!sctp_is_any(sk, ( union sctp_addr *)&params.spp_address)) {
+	if (!sctp_is_any(sk, (union sctp_addr *)&params.spp_address)) {
 		trans = sctp_addr_id2transport(sk, &params.spp_address,
 					       params.spp_assoc_id);
 		if (!trans) {
@@ -4578,7 +4578,7 @@ static int sctp_getsockopt_delayed_ack(struct sock *sk, int len,
 		if (copy_from_user(&params, optval, len))
 			return -EFAULT;
 	} else
-		return - EINVAL;
+		return -EINVAL;
 
 	/* Get association, if sack_assoc_id != 0 and the socket is a one
 	 * to many style socket, and an association was not found, then
@@ -4668,8 +4668,8 @@ static int sctp_getsockopt_peer_addrs(struct sock *sk, int len,
 	if (!asoc)
 		return -EINVAL;
 
-	to = optval + offsetof(struct sctp_getaddrs,addrs);
-	space_left = len - offsetof(struct sctp_getaddrs,addrs);
+	to = optval + offsetof(struct sctp_getaddrs, addrs);
+	space_left = len - offsetof(struct sctp_getaddrs, addrs);
 
 	list_for_each_entry(from, &asoc->peer.transport_addr_list,
 				transports) {
@@ -4729,7 +4729,7 @@ static int sctp_copy_laddrs(struct sock *sk, __u16 port, void *to,
 		memcpy(to, &temp, addrlen);
 
 		to += addrlen;
-		cnt ++;
+		cnt++;
 		space_left -= addrlen;
 		*bytes_copied += addrlen;
 	}
@@ -4778,8 +4778,8 @@ static int sctp_getsockopt_local_addrs(struct sock *sk, int len,
 		bp = &asoc->base.bind_addr;
 	}
 
-	to = optval + offsetof(struct sctp_getaddrs,addrs);
-	space_left = len - offsetof(struct sctp_getaddrs,addrs);
+	to = optval + offsetof(struct sctp_getaddrs, addrs);
+	space_left = len - offsetof(struct sctp_getaddrs, addrs);
 
 	addrs = kmalloc(space_left, GFP_KERNEL);
 	if (!addrs)
@@ -4818,7 +4818,7 @@ static int sctp_getsockopt_local_addrs(struct sock *sk, int len,
 		memcpy(buf, &temp, addrlen);
 		buf += addrlen;
 		bytes_copied += addrlen;
-		cnt ++;
+		cnt++;
 		space_left -= addrlen;
 	}
 
@@ -5090,7 +5090,7 @@ static int sctp_getsockopt_associnfo(struct sock *sk, int len,
 		assocparams.sasoc_cookie_life = ktime_to_ms(asoc->cookie_life);
 
 		list_for_each(pos, &asoc->peer.transport_addr_list) {
-			cnt ++;
+			cnt++;
 		}
 
 		assocparams.sasoc_number_peer_destinations = cnt;
diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
index a674700..2d96640 100644
--- a/net/sctp/ulpqueue.c
+++ b/net/sctp/ulpqueue.c
@@ -107,7 +107,7 @@ int sctp_ulpq_tail_data(struct sctp_ulpq *ulpq, struct sctp_chunk *chunk,
 	event = sctp_ulpq_reasm(ulpq, event);
 
 	/* Do ordering if needed.  */
-	if ((event) && (event->msg_flags & MSG_EOR)){
+	if ((event) && (event->msg_flags & MSG_EOR)) {
 		/* Create a temporary list to collect chunks on.  */
 		skb_queue_head_init(&temp);
 		__skb_queue_tail(&temp, sctp_event2skb(event));
@@ -726,7 +726,7 @@ static void sctp_ulpq_reasm_drain(struct sctp_ulpq *ulpq)
 
 	while ((event = sctp_ulpq_retrieve_reassembled(ulpq)) != NULL) {
 		/* Do ordering if needed.  */
-		if ((event) && (event->msg_flags & MSG_EOR)){
+		if ((event) && (event->msg_flags & MSG_EOR)) {
 			skb_queue_head_init(&temp);
 			__skb_queue_tail(&temp, sctp_event2skb(event));
 
-- 
1.7.12
