From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 51/64] Bluetooth: Implement missing parts of the Invalid Frame Detection
Date: Mon, 10 May 2010 11:37:41 +0200
Message-ID: <18778a63ddc83bc89bda3b119fb02eb121512a66.1273484098.git.marcel@holtmann.org>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53454 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755918Ab0EJJjK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 05:39:10 -0400
In-Reply-To: <f11d676da4059c7888efca810ab300b931736a26.1273484098.git.marcel@holtmann.org>
In-Reply-To: <cover.1273484094.git.marcel@holtmann.org>
References: <cover.1273484094.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Gustavo F. Padovan <padovan@profusion.mobi>

There is a plenty of situation where ERTM shall close the channel, this
commit treats the cases regarding Invalid Frame Detection.
It create one reassembly SDU function for ERTM and other for Streaming
Mode to make the Invalid Frame Detection handling less complex.

Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>
Reviewed-by: Jo=C3=A3o Paulo Rechi Vita <jprvita@profusion.mobi>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/l2cap.c |  119 +++++++++++++++++++++++++++++++++++++++++=
+++++---
 1 files changed, 112 insertions(+), 7 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 1c35c32..cfd6724 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -3329,12 +3329,111 @@ static void l2cap_add_to_srej_queue(struct soc=
k *sk, struct sk_buff *skb, u8 tx_
 	__skb_queue_tail(SREJ_QUEUE(sk), skb);
 }
=20
-static int l2cap_sar_reassembly_sdu(struct sock *sk, struct sk_buff *s=
kb, u16 control)
+static int l2cap_ertm_reassembly_sdu(struct sock *sk, struct sk_buff *=
skb, u16 control)
+{
+	struct l2cap_pinfo *pi =3D l2cap_pi(sk);
+	struct sk_buff *_skb;
+	int err =3D 0;
+
+	switch (control & L2CAP_CTRL_SAR) {
+	case L2CAP_SDU_UNSEGMENTED:
+		if (pi->conn_state & L2CAP_CONN_SAR_SDU)
+			goto drop;
+
+		err =3D sock_queue_rcv_skb(sk, skb);
+		if (!err)
+			return err;
+
+		break;
+
+	case L2CAP_SDU_START:
+		if (pi->conn_state & L2CAP_CONN_SAR_SDU)
+			goto drop;
+
+		pi->sdu_len =3D get_unaligned_le16(skb->data);
+		skb_pull(skb, 2);
+
+		if (pi->sdu_len > pi->imtu)
+			goto disconnect;
+
+		pi->sdu =3D bt_skb_alloc(pi->sdu_len, GFP_ATOMIC);
+		if (!pi->sdu) {
+			err =3D -ENOMEM;
+			break;
+		}
+
+		memcpy(skb_put(pi->sdu, skb->len), skb->data, skb->len);
+
+		pi->conn_state |=3D L2CAP_CONN_SAR_SDU;
+		pi->partial_sdu_len =3D skb->len;
+		break;
+
+	case L2CAP_SDU_CONTINUE:
+		if (!(pi->conn_state & L2CAP_CONN_SAR_SDU))
+			goto disconnect;
+
+		if (!pi->sdu)
+			goto disconnect;
+
+		memcpy(skb_put(pi->sdu, skb->len), skb->data, skb->len);
+
+		pi->partial_sdu_len +=3D skb->len;
+		if (pi->partial_sdu_len > pi->sdu_len)
+			goto drop;
+
+		break;
+
+	case L2CAP_SDU_END:
+		if (!(pi->conn_state & L2CAP_CONN_SAR_SDU))
+			goto disconnect;
+
+		if (!pi->sdu)
+			goto disconnect;
+
+		memcpy(skb_put(pi->sdu, skb->len), skb->data, skb->len);
+
+		pi->conn_state &=3D ~L2CAP_CONN_SAR_SDU;
+		pi->partial_sdu_len +=3D skb->len;
+
+		if (pi->partial_sdu_len > pi->imtu)
+			goto drop;
+
+		if (pi->partial_sdu_len !=3D pi->sdu_len)
+			goto drop;
+
+		_skb =3D skb_clone(pi->sdu, GFP_ATOMIC);
+		err =3D sock_queue_rcv_skb(sk, _skb);
+		if (err < 0)
+			kfree_skb(_skb);
+
+		kfree_skb(pi->sdu);
+		break;
+	}
+
+	kfree_skb(skb);
+	return err;
+
+drop:
+	kfree_skb(pi->sdu);
+	pi->sdu =3D NULL;
+
+disconnect:
+	l2cap_send_disconn_req(pi->conn, sk);
+	kfree_skb(skb);
+	return 0;
+}
+
+static int l2cap_streaming_reassembly_sdu(struct sock *sk, struct sk_b=
uff *skb, u16 control)
 {
 	struct l2cap_pinfo *pi =3D l2cap_pi(sk);
 	struct sk_buff *_skb;
 	int err =3D -EINVAL;
=20
+	/*
+	 * TODO: We have to notify the userland if some data is lost with the
+	 * Streaming Mode.
+	 */
+
 	switch (control & L2CAP_CTRL_SAR) {
 	case L2CAP_SDU_UNSEGMENTED:
 		if (pi->conn_state & L2CAP_CONN_SAR_SDU) {
@@ -3429,7 +3528,7 @@ static void l2cap_check_srej_gap(struct sock *sk,=
 u8 tx_seq)
=20
 		skb =3D skb_dequeue(SREJ_QUEUE(sk));
 		control =3D bt_cb(skb)->sar << L2CAP_CTRL_SAR_SHIFT;
-		l2cap_sar_reassembly_sdu(sk, skb, control);
+		l2cap_ertm_reassembly_sdu(sk, skb, control);
 		l2cap_pi(sk)->buffer_seq_srej =3D
 			(l2cap_pi(sk)->buffer_seq_srej + 1) % 64;
 		tx_seq++;
@@ -3566,7 +3665,7 @@ expected:
=20
 	pi->buffer_seq =3D (pi->buffer_seq + 1) % 64;
=20
-	err =3D l2cap_sar_reassembly_sdu(sk, skb, rx_control);
+	err =3D l2cap_ertm_reassembly_sdu(sk, skb, rx_control);
 	if (err < 0)
 		return err;
=20
@@ -3790,8 +3889,10 @@ static inline int l2cap_data_channel(struct l2ca=
p_conn *conn, u16 cid, struct sk
 		 * Receiver will miss it and start proper recovery
 		 * procedures and ask retransmission.
 		 */
-		if (len > pi->mps)
+		if (len > pi->mps) {
+			l2cap_send_disconn_req(pi->conn, sk);
 			goto drop;
+		}
=20
 		if (l2cap_check_fcs(pi, skb))
 			goto drop;
@@ -3813,13 +3914,17 @@ static inline int l2cap_data_channel(struct l2c=
ap_conn *conn, u16 cid, struct sk
 		}
=20
 		if (__is_iframe(control)) {
-			if (len < 4)
+			if (len < 4) {
+				l2cap_send_disconn_req(pi->conn, sk);
 				goto drop;
+			}
=20
 			l2cap_data_channel_iframe(sk, control, skb);
 		} else {
-			if (len !=3D 0)
+			if (len !=3D 0) {
+				l2cap_send_disconn_req(pi->conn, sk);
 				goto drop;
+			}
=20
 			l2cap_data_channel_sframe(sk, control, skb);
 		}
@@ -3850,7 +3955,7 @@ static inline int l2cap_data_channel(struct l2cap=
_conn *conn, u16 cid, struct sk
 		else
 			pi->expected_tx_seq =3D (tx_seq + 1) % 64;
=20
-		l2cap_sar_reassembly_sdu(sk, skb, control);
+		l2cap_streaming_reassembly_sdu(sk, skb, control);
=20
 		goto done;
=20
--=20
1.6.6.1

