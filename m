From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 53/64] Bluetooth: Implement Local Busy Condition handling
Date: Mon, 10 May 2010 11:37:43 +0200
Message-ID: <1890d36bb556a27684ad29654a9898ab9a5f57ee.1273484098.git.marcel@holtmann.org>
References: <cover.1273484094.git.marcel@holtmann.org>
 <fe1aff710756ac73c455d214845c74e304d0e966.1273484095.git.marcel@holtmann.org>
 <acce90d6a957812081b83ac4d1133e93a43569c6.1273484095.git.marcel@holtmann.org>
 <4f7ac1814ef6f0773e57ffd159a1dd57a3c80521.1273484095.git.marcel@holtmann.org>
 <0d861d8b8edd139a9b291cb262d08dec8dc3922d.1273484095.git.marcel@holtmann.org>
 <b9dbdbc1f4404cba2e64939c30c87d59c9796e4e.1273484095.git.marcel@holtmann.org>
 <c69163e9ed5048407cc84f439cbfecc53f6f7131.1273484095.git.marcel@holtmann.org>
 <faaebd192ec9c3febcab98149d1309199a5b886c.1273484095.git.marcel@holtmann.org>
 <7dffe4210233a2860c3f41477c40b3252edf2b7d.1273484095.git.marcel@holtmann.org>
 <d1daa091e8612f3aab14d28b5836375fafe155e1.1273484096.git.marcel@holtmann.org>
 <e8235c6bdd1c7ffbaa7eb8dcdbb46c51f1e5d72e.1273484096.git.marcel@holtmann.org>
 <d5392c8f1e9faef089bb7cb66c3314da8bddd1fe.1273484096.git.marcel@holtmann.org>
 <1d8f5d16913d74e428950ee02fe9ff7e6391c120.1273484096.git.marcel@holtmann.org>
 <277ffbe362823d18a17792fbd8e507010e666299.1273484096.git.marcel@holtmann.org>
 <36f2fd585f43199f006a3b5ff84e95815102cd31.1273484096.git.marcel@holtmann.org>
 <9e917af13d59182f95bbb5483dc0c4254dfb7944.1273484096.git.marcel@holtmann.org>
 <f0946ccfc7da403a46b7ff7cb2e3deffac108742.1273484096.git.marcel@holtmann.org>
 <73edaa9933219e25d6733b78d1e2c881025705e2.1273484096.git.marcel@holtmann.org>
 <e072745f4adb01b909bd08a0cfc8f79348f4d2c6.1273484096.git.marcel@holtmann.org>
 <99b0d4b7b09edeacf4542bced5c01239375b51a9.1273484096.git.marcel@holtmann.org>
 <6e3a59819fac19006fe4255b87928e5a12c54532.1273484096.git.marcel@holtmann.org>
 <8abb52ee00c4b3f857269eb6b7145991bab869bf.1273484096.git.marcel@holtmann.org>
 <05fbd89dd4153341717b33d9e8ae8bd29db6c1c8.1273484096.git.marcel@holtmann.org>
 <c1b4f43be01c2a363be021485dd18cca33cfab8a.1273484097.git.marcel@holtmann.org>
 <2fb862e215e53630066c677e06d7551fa38bf235.1273484097.git.marcel@holtmann.org>
 <7b1c0049be3aabc18831ada339dbcf41ba8c81fd.1273484097.git.marcel@holtmann.org>
 <1c7621596d11b9c3e19eb88a818758dee4901c95.1273484097.git.marcel@holtmann.org>
 <10467e9e9b89272b25b56688bb276d0830e9ab9a.1273484097.git.marcel@holtmann.org>
 <052897ca5019d9157ae09e5e84eee2a9ef5dccc6.1273484097.git.marcel@holtmann.org>
 <855666cccc939d392316de17512e17a08b2fa05a.1273484097.git.marcel@holtmann.org>
 <14b5aa71ec506f4e38ca6a1dc02ecd668ecfd902.1273484097.git.marcel@holtmann.org>
 <803020c6fa63aa738cfda3329c9675b42023e9d2.1273484097.git.marcel@holtmann.org>
 <369ba30264826f38eefc61b93688100be8adbd4d.1273484097.git.marcel@holtmann.org>
 <68d7f0ce911e41e463c45911be031cdf6a096fe8.1273484097.git.marcel@holtmann.org>
 <f6e6b16823de0aff31cb8ee8c098383e3aceec58.1273484097.git.marcel@holtmann.org>
 <0ee0d20855ae9271de3f6695f4cafc08ab2533bb.1273484097.git.marcel@holtmann.org>
 <812e737e29a1d559e7bfbea675fdcfcbad9f5e1f.1273484097.git.marcel@holtmann.org>
 <3b1a9f3fa6ad842991538da2c3b2e29e047b131f.1273484097.git.marcel@holtmann.org>
 <84fb0a6334af0ccad3544f6972c055d90fbb9fbe.1273484097.git.marcel@holtmann.org>
 <bd3c9e255e76ae232d417e3914ca5d80ca3e9485.1273484097.git.marcel@holtmann.org>
 <0041ecfa3025d7612fdaab12b2f07c9c3c09f42f.1273484098.git.marcel@holtmann.org>
 <afefdbc4cf3b9d409d07e1e5264e7ff88bc48711.1273484098.git.marcel@holtmann.org>
 <01760bdde9a92413b7fff928d08e19352bf09d82.1273484098.git.marcel@holtmann.org>
 <44651b85cc3a076147af5d181fc4833ef8debc59.1273484098.git.marcel@holtmann.org>
 <59203a21a56c53afeb6f45e059299e6f1437f30f.1273484098.git.marcel@holtmann.org>
 <0301ef04b5f49a95681694fc0d75af9441faa919.1273484098.git.marcel@holtmann.org>
 <a2e12a2a312f816d5970b0c809d43b399fbfe90c.1273484098.git.marcel@holtmann.org>
 <9b16dc6551cbde65d0ac525af3c46efab53a2c46.1273484098.git.marcel@holtmann.org>
 <ff12fd643334071084b6145cad3793bb6c956638.1273484098.git.marcel@holtmann.org>
 <9a9c6a34416b3743c09c00f3d6708d9df3c21629.1273484098.git.marcel@holtmann.org>
 <f11d676da4059c7888efca810ab300b931736a26.1273484098.git.marcel@holtmann.org>
 <18778a63ddc83bc89bda3b119fb02eb121512a66.1273484098.git.marcel@holtmann.org>
 <9b53350d3cf5b330c3261d89b5e62a2dc25c5653.1273484098.git.marcel@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53475 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755922Ab0EJJjM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 05:39:12 -0400
In-Reply-To: <9b53350d3cf5b330c3261d89b5e62a2dc25c5653.1273484098.git.marcel@holtmann.org>
In-Reply-To: <cover.1273484094.git.marcel@holtmann.org>
References: <cover.1273484094.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Gustavo F. Padovan <padovan@profusion.mobi>

Supports Local Busy condition handling through a waitqueue that wake up=
s
each 200ms and try to push the packets to the upper layer. If it can
push all the queue then it leaves the Local Busy state.

The patch modifies the behaviour of l2cap_ertm_reassembly_sdu() to
support retry of the push operation.

Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>
Reviewed-by: Jo=C3=A3o Paulo Rechi Vita <jprvita@profusion.mobi>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 include/net/bluetooth/l2cap.h |    6 ++
 net/bluetooth/l2cap.c         |  187 +++++++++++++++++++++++++++++++++=
+++-----
 2 files changed, 172 insertions(+), 21 deletions(-)

diff --git a/include/net/bluetooth/l2cap.h b/include/net/bluetooth/l2ca=
p.h
index 8942c2f..d0185cc 100644
--- a/include/net/bluetooth/l2cap.h
+++ b/include/net/bluetooth/l2cap.h
@@ -35,6 +35,7 @@
 #define L2CAP_DEFAULT_MONITOR_TO	12000   /* 12 seconds */
 #define L2CAP_DEFAULT_MAX_PDU_SIZE	672
 #define L2CAP_DEFAULT_ACK_TO		200
+#define L2CAP_LOCAL_BUSY_TRIES		12
=20
 #define L2CAP_CONN_TIMEOUT	(40000) /* 40 seconds */
 #define L2CAP_INFO_TIMEOUT	(4000)  /*  4 seconds */
@@ -294,6 +295,7 @@ struct l2cap_conn {
 #define l2cap_pi(sk) ((struct l2cap_pinfo *) sk)
 #define TX_QUEUE(sk) (&l2cap_pi(sk)->tx_queue)
 #define SREJ_QUEUE(sk) (&l2cap_pi(sk)->srej_queue)
+#define BUSY_QUEUE(sk) (&l2cap_pi(sk)->busy_queue)
 #define SREJ_LIST(sk) (&l2cap_pi(sk)->srej_l.list)
=20
 struct srej_list {
@@ -356,6 +358,8 @@ struct l2cap_pinfo {
 	struct timer_list	ack_timer;
 	struct sk_buff_head	tx_queue;
 	struct sk_buff_head	srej_queue;
+	struct sk_buff_head	busy_queue;
+	struct work_struct	busy_work;
 	struct srej_list	srej_l;
 	struct l2cap_conn	*conn;
 	struct sock		*next_c;
@@ -383,6 +387,8 @@ struct l2cap_pinfo {
 #define L2CAP_CONN_LOCAL_BUSY      0x0040
 #define L2CAP_CONN_REJ_ACT         0x0080
 #define L2CAP_CONN_SEND_FBIT       0x0100
+#define L2CAP_CONN_RNR_SENT        0x0200
+#define L2CAP_CONN_SAR_RETRY       0x0400
=20
 #define __mod_retrans_timer() mod_timer(&l2cap_pi(sk)->retrans_timer, =
\
 		jiffies +  msecs_to_jiffies(L2CAP_DEFAULT_RETRANS_TO));
diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 481cec2..103e4b5 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -68,10 +68,14 @@ static u8 l2cap_fixed_chan[8] =3D { 0x02, };
=20
 static const struct proto_ops l2cap_sock_ops;
=20
+static struct workqueue_struct *_busy_wq;
+
 static struct bt_sock_list l2cap_sk_list =3D {
 	.lock =3D __RW_LOCK_UNLOCKED(l2cap_sk_list.lock)
 };
=20
+static void l2cap_busy_work(struct work_struct *work);
+
 static void __l2cap_sock_close(struct sock *sk, int reason);
 static void l2cap_sock_close(struct sock *sk);
 static void l2cap_sock_kill(struct sock *sk);
@@ -386,9 +390,10 @@ static inline void l2cap_send_sframe(struct l2cap_=
pinfo *pi, u16 control)
=20
 static inline void l2cap_send_rr_or_rnr(struct l2cap_pinfo *pi, u16 co=
ntrol)
 {
-	if (pi->conn_state & L2CAP_CONN_LOCAL_BUSY)
+	if (pi->conn_state & L2CAP_CONN_LOCAL_BUSY) {
 		control |=3D L2CAP_SUPER_RCV_NOT_READY;
-	else
+		pi->conn_state |=3D L2CAP_CONN_RNR_SENT;
+	} else
 		control |=3D L2CAP_SUPER_RCV_READY;
=20
 	control |=3D pi->buffer_seq << L2CAP_CTRL_REQSEQ_SHIFT;
@@ -816,6 +821,7 @@ static void l2cap_sock_init(struct sock *sk, struct=
 sock *parent)
 	pi->flush_to =3D L2CAP_DEFAULT_FLUSH_TO;
 	skb_queue_head_init(TX_QUEUE(sk));
 	skb_queue_head_init(SREJ_QUEUE(sk));
+	skb_queue_head_init(BUSY_QUEUE(sk));
 	INIT_LIST_HEAD(SREJ_LIST(sk));
 }
=20
@@ -1439,6 +1445,7 @@ static void l2cap_send_ack(struct l2cap_pinfo *pi=
)
=20
 	if (pi->conn_state & L2CAP_CONN_LOCAL_BUSY) {
 		control |=3D L2CAP_SUPER_RCV_NOT_READY;
+		pi->conn_state |=3D L2CAP_CONN_RNR_SENT;
 		l2cap_send_sframe(pi, control);
 		return;
 	} else if (l2cap_ertm_send(sk) =3D=3D 0) {
@@ -2279,6 +2286,9 @@ static inline void l2cap_ertm_init(struct sock *s=
k)
 			l2cap_ack_timeout, (unsigned long) sk);
=20
 	__skb_queue_head_init(SREJ_QUEUE(sk));
+	__skb_queue_head_init(BUSY_QUEUE(sk));
+
+	INIT_WORK(&l2cap_pi(sk)->busy_work, l2cap_busy_work);
 }
=20
 static int l2cap_mode_supported(__u8 mode, __u32 feat_mask)
@@ -3046,6 +3056,7 @@ static inline int l2cap_disconnect_req(struct l2c=
ap_conn *conn, struct l2cap_cmd
=20
 	if (l2cap_pi(sk)->mode =3D=3D L2CAP_MODE_ERTM) {
 		skb_queue_purge(SREJ_QUEUE(sk));
+		skb_queue_purge(BUSY_QUEUE(sk));
 		del_timer(&l2cap_pi(sk)->retrans_timer);
 		del_timer(&l2cap_pi(sk)->monitor_timer);
 		del_timer(&l2cap_pi(sk)->ack_timer);
@@ -3077,6 +3088,7 @@ static inline int l2cap_disconnect_rsp(struct l2c=
ap_conn *conn, struct l2cap_cmd
=20
 	if (l2cap_pi(sk)->mode =3D=3D L2CAP_MODE_ERTM) {
 		skb_queue_purge(SREJ_QUEUE(sk));
+		skb_queue_purge(BUSY_QUEUE(sk));
 		del_timer(&l2cap_pi(sk)->retrans_timer);
 		del_timer(&l2cap_pi(sk)->monitor_timer);
 		del_timer(&l2cap_pi(sk)->ack_timer);
@@ -3287,6 +3299,7 @@ static inline void l2cap_send_i_or_rr_or_rnr(stru=
ct sock *sk)
 	if (pi->conn_state & L2CAP_CONN_LOCAL_BUSY) {
 		control |=3D L2CAP_SUPER_RCV_NOT_READY | L2CAP_CTRL_FINAL;
 		l2cap_send_sframe(pi, control);
+		pi->conn_state |=3D L2CAP_CONN_RNR_SENT;
 		pi->conn_state &=3D ~L2CAP_CONN_SEND_FBIT;
 	}
=20
@@ -3338,7 +3351,7 @@ static int l2cap_ertm_reassembly_sdu(struct sock =
*sk, struct sk_buff *skb, u16 c
 {
 	struct l2cap_pinfo *pi =3D l2cap_pi(sk);
 	struct sk_buff *_skb;
-	int err =3D 0;
+	int err;
=20
 	switch (control & L2CAP_CTRL_SAR) {
 	case L2CAP_SDU_UNSEGMENTED:
@@ -3356,16 +3369,18 @@ static int l2cap_ertm_reassembly_sdu(struct soc=
k *sk, struct sk_buff *skb, u16 c
 			goto drop;
=20
 		pi->sdu_len =3D get_unaligned_le16(skb->data);
-		skb_pull(skb, 2);
=20
 		if (pi->sdu_len > pi->imtu)
 			goto disconnect;
=20
 		pi->sdu =3D bt_skb_alloc(pi->sdu_len, GFP_ATOMIC);
-		if (!pi->sdu) {
-			err =3D -ENOMEM;
-			break;
-		}
+		if (!pi->sdu)
+			return -ENOMEM;
+
+		/* pull sdu_len bytes only after alloc, because of Local Busy
+		 * condition we have to be sure that this will be executed
+		 * only once, i.e., when alloc does not fail */
+		skb_pull(skb, 2);
=20
 		memcpy(skb_put(pi->sdu, skb->len), skb->data, skb->len);
=20
@@ -3395,28 +3410,40 @@ static int l2cap_ertm_reassembly_sdu(struct soc=
k *sk, struct sk_buff *skb, u16 c
 		if (!pi->sdu)
 			goto disconnect;
=20
-		memcpy(skb_put(pi->sdu, skb->len), skb->data, skb->len);
+		if (!(pi->conn_state & L2CAP_CONN_SAR_RETRY)) {
+			memcpy(skb_put(pi->sdu, skb->len), skb->data, skb->len);
=20
-		pi->conn_state &=3D ~L2CAP_CONN_SAR_SDU;
-		pi->partial_sdu_len +=3D skb->len;
+			pi->partial_sdu_len +=3D skb->len;
=20
-		if (pi->partial_sdu_len > pi->imtu)
-			goto drop;
+			if (pi->partial_sdu_len > pi->imtu)
+				goto drop;
=20
-		if (pi->partial_sdu_len !=3D pi->sdu_len)
-			goto drop;
+			if (pi->partial_sdu_len !=3D pi->sdu_len)
+				goto drop;
+		}
=20
 		_skb =3D skb_clone(pi->sdu, GFP_ATOMIC);
+		if (!_skb) {
+			pi->conn_state |=3D L2CAP_CONN_SAR_RETRY;
+			return -ENOMEM;
+		}
+
 		err =3D sock_queue_rcv_skb(sk, _skb);
-		if (err < 0)
+		if (err < 0) {
 			kfree_skb(_skb);
+			pi->conn_state |=3D L2CAP_CONN_SAR_RETRY;
+			return err;
+		}
+
+		pi->conn_state &=3D ~L2CAP_CONN_SAR_RETRY;
+		pi->conn_state &=3D ~L2CAP_CONN_SAR_SDU;
=20
 		kfree_skb(pi->sdu);
 		break;
 	}
=20
 	kfree_skb(skb);
-	return err;
+	return 0;
=20
 drop:
 	kfree_skb(pi->sdu);
@@ -3428,6 +3455,115 @@ disconnect:
 	return 0;
 }
=20
+static void l2cap_busy_work(struct work_struct *work)
+{
+	DECLARE_WAITQUEUE(wait, current);
+	struct l2cap_pinfo *pi =3D
+		container_of(work, struct l2cap_pinfo, busy_work);
+	struct sock *sk =3D (struct sock *)pi;
+	int n_tries =3D 0, timeo =3D HZ/5, err;
+	struct sk_buff *skb;
+	u16 control;
+
+	lock_sock(sk);
+
+	add_wait_queue(sk->sk_sleep, &wait);
+	while ((skb =3D skb_peek(BUSY_QUEUE(sk)))) {
+		set_current_state(TASK_INTERRUPTIBLE);
+
+		if (n_tries++ > L2CAP_LOCAL_BUSY_TRIES) {
+			err =3D -EBUSY;
+			l2cap_send_disconn_req(pi->conn, sk);
+			goto done;
+		}
+
+		if (!timeo)
+			timeo =3D HZ/5;
+
+		if (signal_pending(current)) {
+			err =3D sock_intr_errno(timeo);
+			goto done;
+		}
+
+		release_sock(sk);
+		timeo =3D schedule_timeout(timeo);
+		lock_sock(sk);
+
+		err =3D sock_error(sk);
+		if (err)
+			goto done;
+
+		while ((skb =3D skb_dequeue(BUSY_QUEUE(sk)))) {
+			control =3D bt_cb(skb)->sar << L2CAP_CTRL_SAR_SHIFT;
+			err =3D l2cap_ertm_reassembly_sdu(sk, skb, control);
+			if (err < 0) {
+				skb_queue_head(BUSY_QUEUE(sk), skb);
+				break;
+			}
+
+			pi->buffer_seq =3D (pi->buffer_seq + 1) % 64;
+		}
+
+		if (!skb)
+			break;
+	}
+
+	if (!(pi->conn_state & L2CAP_CONN_RNR_SENT))
+		goto done;
+
+	control =3D pi->buffer_seq << L2CAP_CTRL_REQSEQ_SHIFT;
+	control |=3D L2CAP_SUPER_RCV_READY | L2CAP_CTRL_POLL;
+	l2cap_send_sframe(pi, control);
+	l2cap_pi(sk)->retry_count =3D 1;
+
+	del_timer(&pi->retrans_timer);
+	__mod_monitor_timer();
+
+	l2cap_pi(sk)->conn_state |=3D L2CAP_CONN_WAIT_F;
+
+done:
+	pi->conn_state &=3D ~L2CAP_CONN_LOCAL_BUSY;
+	pi->conn_state &=3D ~L2CAP_CONN_RNR_SENT;
+
+	set_current_state(TASK_RUNNING);
+	remove_wait_queue(sk->sk_sleep, &wait);
+
+	release_sock(sk);
+}
+
+static int l2cap_push_rx_skb(struct sock *sk, struct sk_buff *skb, u16=
 control)
+{
+	struct l2cap_pinfo *pi =3D l2cap_pi(sk);
+	int sctrl, err;
+
+	if (pi->conn_state & L2CAP_CONN_LOCAL_BUSY) {
+		bt_cb(skb)->sar =3D control >> L2CAP_CTRL_SAR_SHIFT;
+		__skb_queue_tail(BUSY_QUEUE(sk), skb);
+		return -EBUSY;
+	}
+
+	err =3D l2cap_ertm_reassembly_sdu(sk, skb, control);
+	if (err >=3D 0) {
+		pi->buffer_seq =3D (pi->buffer_seq + 1) % 64;
+		return err;
+	}
+
+	/* Busy Condition */
+	pi->conn_state |=3D L2CAP_CONN_LOCAL_BUSY;
+	bt_cb(skb)->sar =3D control >> L2CAP_CTRL_SAR_SHIFT;
+	__skb_queue_tail(BUSY_QUEUE(sk), skb);
+
+	sctrl =3D pi->buffer_seq << L2CAP_CTRL_REQSEQ_SHIFT;
+	sctrl |=3D L2CAP_SUPER_RCV_NOT_READY;
+	l2cap_send_sframe(pi, sctrl);
+
+	pi->conn_state |=3D L2CAP_CONN_RNR_SENT;
+
+	queue_work(_busy_wq, &pi->busy_work);
+
+	return err;
+}
+
 static int l2cap_streaming_reassembly_sdu(struct sock *sk, struct sk_b=
uff *skb, u16 control)
 {
 	struct l2cap_pinfo *pi =3D l2cap_pi(sk);
@@ -3614,6 +3750,9 @@ static inline int l2cap_data_channel_iframe(struc=
t sock *sk, u16 rx_control, str
 		goto drop;
 	}
=20
+	if (pi->conn_state =3D=3D L2CAP_CONN_LOCAL_BUSY)
+		goto drop;
+
 	if (pi->conn_state & L2CAP_CONN_SREJ_SENT) {
 		struct srej_list *first;
=20
@@ -3662,6 +3801,7 @@ static inline int l2cap_data_channel_iframe(struc=
t sock *sk, u16 rx_control, str
 		pi->buffer_seq_srej =3D pi->buffer_seq;
=20
 		__skb_queue_head_init(SREJ_QUEUE(sk));
+		__skb_queue_head_init(BUSY_QUEUE(sk));
 		l2cap_add_to_srej_queue(sk, skb, tx_seq, sar);
=20
 		pi->conn_state |=3D L2CAP_CONN_SEND_PBIT;
@@ -3691,11 +3831,9 @@ expected:
 		}
 	}
=20
-	pi->buffer_seq =3D (pi->buffer_seq + 1) % 64;
-
-	err =3D l2cap_ertm_reassembly_sdu(sk, skb, rx_control);
+	err =3D l2cap_push_rx_skb(sk, skb, rx_control);
 	if (err < 0)
-		return err;
+		return 0;
=20
 	__mod_ack_timer();
=20
@@ -4406,6 +4544,10 @@ static int __init l2cap_init(void)
 	if (err < 0)
 		return err;
=20
+	_busy_wq =3D create_singlethread_workqueue("l2cap");
+	if (!_busy_wq)
+		goto error;
+
 	err =3D bt_sock_register(BTPROTO_L2CAP, &l2cap_sock_family_ops);
 	if (err < 0) {
 		BT_ERR("L2CAP socket registration failed");
@@ -4440,6 +4582,9 @@ static void __exit l2cap_exit(void)
 {
 	debugfs_remove(l2cap_debugfs);
=20
+	flush_workqueue(_busy_wq);
+	destroy_workqueue(_busy_wq);
+
 	if (bt_sock_unregister(BTPROTO_L2CAP) < 0)
 		BT_ERR("L2CAP socket unregistration failed");
=20
--=20
1.6.6.1

