From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 46/47] Bluetooth: Handle L2CAP case when the remote receiver is busy
Date: Sun, 30 Aug 2009 01:51:00 -0700
Message-ID: <2246b2f1b43f3fbd128e72b129dcbbd3202cc592.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
 <fd0b3ff707dc1f7837079044bd4eca7ed505f70d.1251621661.git.marcel@holtmann.org>
 <981b1414d78a7a42cab48b97d4de54a62d61db88.1251621661.git.marcel@holtmann.org>
 <290ba200815fdecb4d40dc942499c4ea6d0c4624.1251621661.git.marcel@holtmann.org>
 <364f63519d94442ed373ac7da79033c8282df46a.1251621661.git.marcel@holtmann.org>
 <9eba32b86d17ef87131fa0bce43c614904ab5781.1251621661.git.marcel@holtmann.org>
 <edad63886993d18ab800c49f6587a93432ef8b35.1251621661.git.marcel@holtmann.org>
 <132ff4e5fa8dfb71a7d99902f88043113947e972.1251621661.git.marcel@holtmann.org>
 <789221ecc870117b77e354d488d5d29f15410de8.1251621661.git.marcel@holtmann.org>
 <fb784f0508d5aa39a23e72879a8dfb517c6f6e7f.1251621661.git.marcel@holtmann.org>
 <196be0cd018068d545e1d764094c7b07aaf0bcfe.1251621661.git.marcel@holtmann.org>
 <e7a25f9839fd392ec2c96e7e2b3734501d761a24.1251621661.git.marcel@holtmann.org>
 <08b0b0ce8c609b0e2284b134f0614e211374a038.1251621661.git.marcel@holtmann.org>
 <944fe798c6a48336e82bbc0d4e280587325a4d95.1251621661.git.marcel@holtmann.org>
 <542399037d0cb2b2e96dfb8ced35b07dfb1c3706.1251621661.git.marcel@holtmann.org>
 <4271e08d8b799171af18d7864908ec444282efe5.1251621661.git.marcel@holtmann.org>
 <dcf47f3bc798888f9ea40b9f626d669dc62086bf.1251621661.git.marcel@holtmann.org>
 <9666fb356da78a5ec28403197d72e8cd6aa16424.1251621661.git.marcel@holtmann.org>
 <60dee5ccd789ee8a380eee802b6cb24c52123428.1251621661.git.marcel@holtmann.org>
 <91d697302b291205171840bfe84c1563e171acb2.1251621661.git.marcel@holtmann.org>
 <e0721f99ba33d13a88746732be2d74ca805abf55.1251621661.git.marcel@holtmann.org>
 <9374253ffe609f2d70dd5ae280182cb6f08fef08.1251621661.git.marcel@holtmann.org>
 <3318b2362bf0528be77123c480249663557dfbfc.1251621661.git.marcel@holtmann.org>
 <5959809ded86e267c1a95fb44738a224c30d3434.1251621661.git.marcel@holtmann.org>
 <a6a67efd7088702fdbbb780c5a3f8e1a74e77b63.1251621661.git.marcel@holtmann.org>
 <52d18347dfb61519aa0f58fe1759edd3ad8c4e36.1251621661.git.marcel@holtmann.org>
 <44dd46de325c4d47abfd1361e5d84a548edb8e42.1251621661.git.marcel@holtmann.org>
 <c6b03cf986eab00e20d0dbc852b233bb83472138.1251621661.git.marcel@holtmann.org>
 <65c7c4918450f8c4545ccb02a9c7a3d77e073535.1251621661.git.marcel@holtmann.org>
 <f2fcfcd670257236ebf2088bbdf26f6a8ef459fe.1251621661.git.marcel@holtmann.org>
 <22121fc9152ca8f25a2d790860832ccb6a414c4d.1251621661.git.marcel@holtmann.org>
 <1c2acffb76d4bc5fd27c4ea55cc27ad8ead10f9a.1251621661.git.marcel@holtmann.org>
 <c74e560cd0101455f1889515e1527e4c2e266113.1251621661.git.marcel@holtmann.org>
 <30afb5b2aa83adf4f69e5090d48e1bb04b64c58a.1251621661.git.marcel@holtmann.org>
 <e90bac061b17cd81bd0df30606c64f4543bf5ca0.1251621661.git.marcel@holtmann.org>
 <6840ed0770d79b9bb0800e5e026a067040ef18f5.1251621661.git.marcel@holtmann.org>
 <fcc203c30d72dde82692f6b761a80e5ca5fdd8fa.1251621661.git.marcel@holtmann.org>
 <8f17154f1f70fcc6faa31ac82164fcf7f0599f38.1251621661.git.marcel@holtmann.org>
 <ef54fd937fbd5ebaeb023818524565bd526a5f36.1251621661.git.marcel@holtmann.org>
 <9e726b17422bade75fba94e625cd35fd1353e682.1251621661.git.marcel@holtmann.org>
 <e686219a64fee9be9ce438dc3f040cd71ddd168a.1251621661.git.marcel@holtmann.org>
 <1b7bf4edca0fdbad70c44e139f4cfebd6759de81.1251621661.git.marcel@holtmann.org>
 <d2e353f7c3c5fbb3add0341c10ae167ee745d23b.1251621661.git.marcel@holtmann.org>
 <7bee549e197c9c0e92b89857a409675c1d5e9dff.1251621661.git.marcel@holtmann.org>
 <cbe86b98a6aceefe943ada1471eb52fd9ac4c504.1251621661.git.marcel@holtmann.org>
 <ca42a613c92d131ff02d5714419d58c36c3459f3.1251621661.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53342 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753340AbZH3Iwp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 04:52:45 -0400
In-Reply-To: <ca42a613c92d131ff02d5714419d58c36c3459f3.1251621661.git.marcel@holtmann.org>
In-Reply-To: <cover.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>

Implement all issues related to RemoteBusy in the RECV state table.

Signed-off-by: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 include/net/bluetooth/l2cap.h |    2 ++
 net/bluetooth/l2cap.c         |   25 +++++++++++++++++++++++--
 2 files changed, 25 insertions(+), 2 deletions(-)

diff --git a/include/net/bluetooth/l2cap.h b/include/net/bluetooth/l2cap.h
index 7ca614a..9516f4b 100644
--- a/include/net/bluetooth/l2cap.h
+++ b/include/net/bluetooth/l2cap.h
@@ -373,6 +373,8 @@ struct l2cap_pinfo {
 #define L2CAP_CONN_WAIT_F          0x04
 #define L2CAP_CONN_SREJ_ACT        0x08
 #define L2CAP_CONN_SEND_PBIT       0x10
+#define L2CAP_CONN_REMOTE_BUSY     0x20
+#define L2CAP_CONN_LOCAL_BUSY      0x40
 
 #define __mod_retrans_timer() mod_timer(&l2cap_pi(sk)->retrans_timer, \
 		jiffies +  msecs_to_jiffies(L2CAP_DEFAULT_RETRANS_TO));
diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 0a36c61..40fbf5c 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -1350,7 +1350,8 @@ static int l2cap_ertm_send(struct sock *sk)
 	if (pi->conn_state & L2CAP_CONN_WAIT_F)
 		return 0;
 
-	while ((skb = sk->sk_send_head) && (!l2cap_tx_window_full(sk))) {
+	while ((skb = sk->sk_send_head) && (!l2cap_tx_window_full(sk))
+			&& !(pi->conn_state & L2CAP_CONN_REMOTE_BUSY)) {
 		tx_skb = skb_clone(skb, GFP_ATOMIC);
 
 		if (pi->remote_max_tx &&
@@ -3351,7 +3352,10 @@ static inline int l2cap_data_channel_sframe(struct sock *sk, u16 rx_control, str
 			control |= L2CAP_SUPER_RCV_READY |
 				(pi->buffer_seq << L2CAP_CTRL_REQSEQ_SHIFT);
 			l2cap_send_sframe(l2cap_pi(sk), control);
+			pi->conn_state &= ~L2CAP_CONN_REMOTE_BUSY;
+
 		} else if (rx_control & L2CAP_CTRL_FINAL) {
+			pi->conn_state &= ~L2CAP_CONN_REMOTE_BUSY;
 			pi->expected_ack_seq = tx_seq;
 			l2cap_drop_acked_frames(sk);
 
@@ -3366,13 +3370,19 @@ static inline int l2cap_data_channel_sframe(struct sock *sk, u16 rx_control, str
 		} else {
 			pi->expected_ack_seq = tx_seq;
 			l2cap_drop_acked_frames(sk);
-			if (pi->unacked_frames > 0)
+
+			if ((pi->conn_state & L2CAP_CONN_REMOTE_BUSY)
+					&& (pi->unacked_frames > 0))
 				__mod_retrans_timer();
+
 			l2cap_ertm_send(sk);
+			pi->conn_state &= ~L2CAP_CONN_REMOTE_BUSY;
 		}
 		break;
 
 	case L2CAP_SUPER_REJECT:
+		pi->conn_state &= ~L2CAP_CONN_REMOTE_BUSY;
+
 		pi->expected_ack_seq = __get_reqseq(rx_control);
 		l2cap_drop_acked_frames(sk);
 
@@ -3384,6 +3394,8 @@ static inline int l2cap_data_channel_sframe(struct sock *sk, u16 rx_control, str
 		break;
 
 	case L2CAP_SUPER_SELECT_REJECT:
+		pi->conn_state &= ~L2CAP_CONN_REMOTE_BUSY;
+
 		if (rx_control & L2CAP_CTRL_POLL) {
 			l2cap_retransmit_frame(sk, tx_seq);
 			pi->expected_ack_seq = tx_seq;
@@ -3410,6 +3422,15 @@ static inline int l2cap_data_channel_sframe(struct sock *sk, u16 rx_control, str
 		break;
 
 	case L2CAP_SUPER_RCV_NOT_READY:
+		pi->conn_state |= L2CAP_CONN_REMOTE_BUSY;
+		pi->expected_ack_seq = tx_seq;
+		l2cap_drop_acked_frames(sk);
+
+		del_timer(&l2cap_pi(sk)->retrans_timer);
+		if (rx_control & L2CAP_CTRL_POLL) {
+			u16 control = L2CAP_CTRL_FINAL | L2CAP_SUPER_RCV_READY;
+			l2cap_send_sframe(l2cap_pi(sk), control);
+		}
 		break;
 	}
 
-- 
1.6.2.5

