From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 49/64] Bluetooth: Make hci_send_acl() void
Date: Mon, 10 May 2010 11:37:39 +0200
Message-ID: <9a9c6a34416b3743c09c00f3d6708d9df3c21629.1273484098.git.marcel@holtmann.org>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53446 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755815Ab0EJJjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 05:39:09 -0400
In-Reply-To: <ff12fd643334071084b6145cad3793bb6c956638.1273484098.git.marcel@holtmann.org>
In-Reply-To: <cover.1273484094.git.marcel@holtmann.org>
References: <cover.1273484094.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Gustavo F. Padovan <padovan@profusion.mobi>

hci_send_acl can't fail, so we can make it void. This patch changes
that and all the funcions that use hci_send_acl().
That change exposed a bug on sending connectionless data. We were not
reporting the lenght send back to the user space.

Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>
Reviewed-by: Jo=C3=A3o Paulo Rechi Vita <jprvita@profusion.mobi>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 include/net/bluetooth/hci_core.h |    2 +-
 net/bluetooth/hci_core.c         |    4 +-
 net/bluetooth/l2cap.c            |   73 ++++++++++++++----------------=
--------
 3 files changed, 30 insertions(+), 49 deletions(-)

diff --git a/include/net/bluetooth/hci_core.h b/include/net/bluetooth/h=
ci_core.h
index 9830a88..4511df2 100644
--- a/include/net/bluetooth/hci_core.h
+++ b/include/net/bluetooth/hci_core.h
@@ -636,7 +636,7 @@ int hci_register_notifier(struct notifier_block *nb=
);
 int hci_unregister_notifier(struct notifier_block *nb);
=20
 int hci_send_cmd(struct hci_dev *hdev, __u16 opcode, __u32 plen, void =
*param);
-int hci_send_acl(struct hci_conn *conn, struct sk_buff *skb, __u16 fla=
gs);
+void hci_send_acl(struct hci_conn *conn, struct sk_buff *skb, __u16 fl=
ags);
 void hci_send_sco(struct hci_conn *conn, struct sk_buff *skb);
=20
 void *hci_sent_cmd_data(struct hci_dev *hdev, __u16 opcode);
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index 1c9aef9..904f1e8 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -1260,7 +1260,7 @@ static void hci_add_acl_hdr(struct sk_buff *skb, =
__u16 handle, __u16 flags)
 	hdr->dlen   =3D cpu_to_le16(len);
 }
=20
-int hci_send_acl(struct hci_conn *conn, struct sk_buff *skb, __u16 fla=
gs)
+void hci_send_acl(struct hci_conn *conn, struct sk_buff *skb, __u16 fl=
ags)
 {
 	struct hci_dev *hdev =3D conn->hdev;
 	struct sk_buff *list;
@@ -1303,7 +1303,7 @@ int hci_send_acl(struct hci_conn *conn, struct sk=
_buff *skb, __u16 flags)
=20
 	tasklet_schedule(&hdev->tx_task);
=20
-	return 0;
+	return;
 }
 EXPORT_SYMBOL(hci_send_acl);
=20
diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 6b08f4d..7e74d5b 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -330,19 +330,19 @@ static inline u8 l2cap_get_ident(struct l2cap_con=
n *conn)
 	return id;
 }
=20
-static inline int l2cap_send_cmd(struct l2cap_conn *conn, u8 ident, u8=
 code, u16 len, void *data)
+static inline void l2cap_send_cmd(struct l2cap_conn *conn, u8 ident, u=
8 code, u16 len, void *data)
 {
 	struct sk_buff *skb =3D l2cap_build_cmd(conn, code, ident, len, data)=
;
=20
 	BT_DBG("code 0x%2.2x", code);
=20
 	if (!skb)
-		return -ENOMEM;
+		return;
=20
-	return hci_send_acl(conn->hcon, skb, 0);
+	hci_send_acl(conn->hcon, skb, 0);
 }
=20
-static inline int l2cap_send_sframe(struct l2cap_pinfo *pi, u16 contro=
l)
+static inline void l2cap_send_sframe(struct l2cap_pinfo *pi, u16 contr=
ol)
 {
 	struct sk_buff *skb;
 	struct l2cap_hdr *lh;
@@ -369,7 +369,7 @@ static inline int l2cap_send_sframe(struct l2cap_pi=
nfo *pi, u16 control)
=20
 	skb =3D bt_skb_alloc(count, GFP_ATOMIC);
 	if (!skb)
-		return -ENOMEM;
+		return;
=20
 	lh =3D (struct l2cap_hdr *) skb_put(skb, L2CAP_HDR_SIZE);
 	lh->len =3D cpu_to_le16(hlen - L2CAP_HDR_SIZE);
@@ -381,10 +381,10 @@ static inline int l2cap_send_sframe(struct l2cap_=
pinfo *pi, u16 control)
 		put_unaligned_le16(fcs, skb_put(skb, 2));
 	}
=20
-	return hci_send_acl(pi->conn->hcon, skb, 0);
+	hci_send_acl(pi->conn->hcon, skb, 0);
 }
=20
-static inline int l2cap_send_rr_or_rnr(struct l2cap_pinfo *pi, u16 con=
trol)
+static inline void l2cap_send_rr_or_rnr(struct l2cap_pinfo *pi, u16 co=
ntrol)
 {
 	if (pi->conn_state & L2CAP_CONN_LOCAL_BUSY)
 		control |=3D L2CAP_SUPER_RCV_NOT_READY;
@@ -393,7 +393,7 @@ static inline int l2cap_send_rr_or_rnr(struct l2cap=
_pinfo *pi, u16 control)
=20
 	control |=3D pi->buffer_seq << L2CAP_CTRL_REQSEQ_SHIFT;
=20
-	return l2cap_send_sframe(pi, control);
+	l2cap_send_sframe(pi, control);
 }
=20
 static void l2cap_do_start(struct sock *sk)
@@ -1289,18 +1289,13 @@ static void l2cap_drop_acked_frames(struct sock=
 *sk)
 	return;
 }
=20
-static inline int l2cap_do_send(struct sock *sk, struct sk_buff *skb)
+static inline void l2cap_do_send(struct sock *sk, struct sk_buff *skb)
 {
 	struct l2cap_pinfo *pi =3D l2cap_pi(sk);
-	int err;
=20
 	BT_DBG("sk %p, skb %p len %d", sk, skb, skb->len);
=20
-	err =3D hci_send_acl(pi->conn->hcon, skb, 0);
-	if (err < 0)
-		kfree_skb(skb);
-
-	return err;
+	hci_send_acl(pi->conn->hcon, skb, 0);
 }
=20
 static int l2cap_streaming_send(struct sock *sk)
@@ -1308,7 +1303,6 @@ static int l2cap_streaming_send(struct sock *sk)
 	struct sk_buff *skb, *tx_skb;
 	struct l2cap_pinfo *pi =3D l2cap_pi(sk);
 	u16 control, fcs;
-	int err;
=20
 	while ((skb =3D sk->sk_send_head)) {
 		tx_skb =3D skb_clone(skb, GFP_ATOMIC);
@@ -1322,11 +1316,7 @@ static int l2cap_streaming_send(struct sock *sk)
 			put_unaligned_le16(fcs, tx_skb->data + tx_skb->len - 2);
 		}
=20
-		err =3D l2cap_do_send(sk, tx_skb);
-		if (err < 0) {
-			l2cap_send_disconn_req(pi->conn, sk);
-			return err;
-		}
+		l2cap_do_send(sk, tx_skb);
=20
 		pi->next_tx_seq =3D (pi->next_tx_seq + 1) % 64;
=20
@@ -1346,7 +1336,6 @@ static int l2cap_retransmit_frame(struct sock *sk=
, u8 tx_seq)
 	struct l2cap_pinfo *pi =3D l2cap_pi(sk);
 	struct sk_buff *skb, *tx_skb;
 	u16 control, fcs;
-	int err;
=20
 	skb =3D skb_peek(TX_QUEUE(sk));
 	do {
@@ -1375,11 +1364,7 @@ static int l2cap_retransmit_frame(struct sock *s=
k, u8 tx_seq)
 			put_unaligned_le16(fcs, tx_skb->data + tx_skb->len - 2);
 		}
=20
-		err =3D l2cap_do_send(sk, tx_skb);
-		if (err < 0) {
-			l2cap_send_disconn_req(pi->conn, sk);
-			return err;
-		}
+		l2cap_do_send(sk, tx_skb);
 		break;
 	} while(1);
 	return 0;
@@ -1390,7 +1375,7 @@ static int l2cap_ertm_send(struct sock *sk)
 	struct sk_buff *skb, *tx_skb;
 	struct l2cap_pinfo *pi =3D l2cap_pi(sk);
 	u16 control, fcs;
-	int err, nsent =3D 0;
+	int nsent =3D 0;
=20
 	if (pi->conn_state & L2CAP_CONN_WAIT_F)
 		return 0;
@@ -1423,11 +1408,8 @@ static int l2cap_ertm_send(struct sock *sk)
 			put_unaligned_le16(fcs, skb->data + tx_skb->len - 2);
 		}
=20
-		err =3D l2cap_do_send(sk, tx_skb);
-		if (err < 0) {
-			l2cap_send_disconn_req(pi->conn, sk);
-			return err;
-		}
+		l2cap_do_send(sk, tx_skb);
+
 		__mod_retrans_timer();
=20
 		bt_cb(skb)->tx_seq =3D pi->next_tx_seq;
@@ -1447,7 +1429,7 @@ static int l2cap_ertm_send(struct sock *sk)
 	return nsent;
 }
=20
-static int l2cap_send_ack(struct l2cap_pinfo *pi)
+static void l2cap_send_ack(struct l2cap_pinfo *pi)
 {
 	struct sock *sk =3D (struct sock *)pi;
 	u16 control =3D 0;
@@ -1456,15 +1438,15 @@ static int l2cap_send_ack(struct l2cap_pinfo *p=
i)
=20
 	if (pi->conn_state & L2CAP_CONN_LOCAL_BUSY) {
 		control |=3D L2CAP_SUPER_RCV_NOT_READY;
-		return l2cap_send_sframe(pi, control);
+		l2cap_send_sframe(pi, control);
+		return;
 	} else if (l2cap_ertm_send(sk) =3D=3D 0) {
 		control |=3D L2CAP_SUPER_RCV_READY;
-		return l2cap_send_sframe(pi, control);
+		l2cap_send_sframe(pi, control);
 	}
-	return 0;
 }
=20
-static int l2cap_send_srejtail(struct sock *sk)
+static void l2cap_send_srejtail(struct sock *sk)
 {
 	struct srej_list *tail;
 	u16 control;
@@ -1476,8 +1458,6 @@ static int l2cap_send_srejtail(struct sock *sk)
 	control |=3D tail->tx_seq << L2CAP_CTRL_REQSEQ_SHIFT;
=20
 	l2cap_send_sframe(l2cap_pi(sk), control);
-
-	return 0;
 }
=20
 static inline int l2cap_skbuff_fromiovec(struct sock *sk, struct msghd=
r *msg, int len, int count, struct sk_buff *skb)
@@ -1687,10 +1667,12 @@ static int l2cap_sock_sendmsg(struct kiocb *ioc=
b, struct socket *sock, struct ms
 	/* Connectionless channel */
 	if (sk->sk_type =3D=3D SOCK_DGRAM) {
 		skb =3D l2cap_create_connless_pdu(sk, msg, len);
-		if (IS_ERR(skb))
+		if (IS_ERR(skb)) {
 			err =3D PTR_ERR(skb);
-		else
-			err =3D l2cap_do_send(sk, skb);
+		} else {
+			l2cap_do_send(sk, skb);
+			err =3D len;
+		}
 		goto done;
 	}
=20
@@ -1709,9 +1691,8 @@ static int l2cap_sock_sendmsg(struct kiocb *iocb,=
 struct socket *sock, struct ms
 			goto done;
 		}
=20
-		err =3D l2cap_do_send(sk, skb);
-		if (!err)
-			err =3D len;
+		l2cap_do_send(sk, skb);
+		err =3D len;
 		break;
=20
 	case L2CAP_MODE_ERTM:
--=20
1.6.6.1

