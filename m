From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 39/64] Bluetooth: Add SOCK_STREAM support to L2CAP
Date: Mon, 10 May 2010 11:37:29 +0200
Message-ID: <bd3c9e255e76ae232d417e3914ca5d80ca3e9485.1273484097.git.marcel@holtmann.org>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53446 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755874Ab0EJJjD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 05:39:03 -0400
In-Reply-To: <84fb0a6334af0ccad3544f6972c055d90fbb9fbe.1273484097.git.marcel@holtmann.org>
In-Reply-To: <cover.1273484094.git.marcel@holtmann.org>
References: <cover.1273484094.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Gustavo F. Padovan <padovan@profusion.mobi>

if enable_ertm is true and we have SOCK_STREAM the default mode will be
ERTM, otherwise Basic Mode.

Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>
Reviewed-by: Jo=C3=A3o Paulo Rechi Vita <jprvita@profusion.mobi>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/l2cap.c |   40 ++++++++++++++++++++++++++--------------
 1 files changed, 26 insertions(+), 14 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 4c00720..1a32562 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -224,7 +224,7 @@ static void __l2cap_chan_add(struct l2cap_conn *con=
n, struct sock *sk, struct so
=20
 	l2cap_pi(sk)->conn =3D conn;
=20
-	if (sk->sk_type =3D=3D SOCK_SEQPACKET) {
+	if (sk->sk_type =3D=3D SOCK_SEQPACKET || sk->sk_type =3D=3D SOCK_STRE=
AM) {
 		/* Alloc CID for connection-oriented socket */
 		l2cap_pi(sk)->scid =3D l2cap_alloc_cid(l);
 	} else if (sk->sk_type =3D=3D SOCK_DGRAM) {
@@ -452,7 +452,8 @@ static void l2cap_conn_start(struct l2cap_conn *con=
n)
 	for (sk =3D l->head; sk; sk =3D l2cap_pi(sk)->next_c) {
 		bh_lock_sock(sk);
=20
-		if (sk->sk_type !=3D SOCK_SEQPACKET) {
+		if (sk->sk_type !=3D SOCK_SEQPACKET &&
+				sk->sk_type !=3D SOCK_STREAM) {
 			bh_unlock_sock(sk);
 			continue;
 		}
@@ -512,7 +513,8 @@ static void l2cap_conn_ready(struct l2cap_conn *con=
n)
 	for (sk =3D l->head; sk; sk =3D l2cap_pi(sk)->next_c) {
 		bh_lock_sock(sk);
=20
-		if (sk->sk_type !=3D SOCK_SEQPACKET) {
+		if (sk->sk_type !=3D SOCK_SEQPACKET &&
+				sk->sk_type !=3D SOCK_STREAM) {
 			l2cap_sock_clear_timer(sk);
 			sk->sk_state =3D BT_CONNECTED;
 			sk->sk_state_change(sk);
@@ -721,7 +723,8 @@ static void __l2cap_sock_close(struct sock *sk, int=
 reason)
=20
 	case BT_CONNECTED:
 	case BT_CONFIG:
-		if (sk->sk_type =3D=3D SOCK_SEQPACKET) {
+		if (sk->sk_type =3D=3D SOCK_SEQPACKET ||
+				sk->sk_type =3D=3D SOCK_STREAM) {
 			struct l2cap_conn *conn =3D l2cap_pi(sk)->conn;
=20
 			sk->sk_state =3D BT_DISCONN;
@@ -732,7 +735,8 @@ static void __l2cap_sock_close(struct sock *sk, int=
 reason)
 		break;
=20
 	case BT_CONNECT2:
-		if (sk->sk_type =3D=3D SOCK_SEQPACKET) {
+		if (sk->sk_type =3D=3D SOCK_SEQPACKET ||
+				sk->sk_type =3D=3D SOCK_STREAM) {
 			struct l2cap_conn *conn =3D l2cap_pi(sk)->conn;
 			struct l2cap_conn_rsp rsp;
 			__u16 result;
@@ -795,7 +799,10 @@ static void l2cap_sock_init(struct sock *sk, struc=
t sock *parent)
 	} else {
 		pi->imtu =3D L2CAP_DEFAULT_MTU;
 		pi->omtu =3D 0;
-		pi->mode =3D L2CAP_MODE_BASIC;
+		if (enable_ertm && sk->sk_type =3D=3D SOCK_STREAM)
+			pi->mode =3D L2CAP_MODE_ERTM;
+		else
+			pi->mode =3D L2CAP_MODE_BASIC;
 		pi->max_tx =3D max_transmit;
 		pi->fcs  =3D L2CAP_FCS_CRC16;
 		pi->tx_win =3D tx_window;
@@ -852,7 +859,7 @@ static int l2cap_sock_create(struct net *net, struc=
t socket *sock, int protocol,
=20
 	sock->state =3D SS_UNCONNECTED;
=20
-	if (sock->type !=3D SOCK_SEQPACKET &&
+	if (sock->type !=3D SOCK_SEQPACKET && sock->type !=3D SOCK_STREAM &&
 			sock->type !=3D SOCK_DGRAM && sock->type !=3D SOCK_RAW)
 		return -ESOCKTNOSUPPORT;
=20
@@ -1000,7 +1007,8 @@ static int l2cap_do_connect(struct sock *sk)
 	l2cap_sock_set_timer(sk, sk->sk_sndtimeo);
=20
 	if (hcon->state =3D=3D BT_CONNECTED) {
-		if (sk->sk_type !=3D SOCK_SEQPACKET) {
+		if (sk->sk_type !=3D SOCK_SEQPACKET &&
+				sk->sk_type !=3D SOCK_STREAM) {
 			l2cap_sock_clear_timer(sk);
 			sk->sk_state =3D BT_CONNECTED;
 		} else
@@ -1034,7 +1042,8 @@ static int l2cap_sock_connect(struct socket *sock=
, struct sockaddr *addr, int al
=20
 	lock_sock(sk);
=20
-	if (sk->sk_type =3D=3D SOCK_SEQPACKET && !la.l2_psm) {
+	if ((sk->sk_type =3D=3D SOCK_SEQPACKET || sk->sk_type =3D=3D SOCK_STR=
EAM)
+			&& !la.l2_psm) {
 		err =3D -EINVAL;
 		goto done;
 	}
@@ -1098,7 +1107,8 @@ static int l2cap_sock_listen(struct socket *sock,=
 int backlog)
=20
 	lock_sock(sk);
=20
-	if (sk->sk_state !=3D BT_BOUND || sock->type !=3D SOCK_SEQPACKET) {
+	if ((sock->type !=3D SOCK_SEQPACKET && sock->type !=3D SOCK_STREAM)
+			|| sk->sk_state !=3D BT_BOUND) {
 		err =3D -EBADFD;
 		goto done;
 	}
@@ -1857,7 +1867,8 @@ static int l2cap_sock_setsockopt(struct socket *s=
ock, int level, int optname, ch
=20
 	switch (optname) {
 	case BT_SECURITY:
-		if (sk->sk_type !=3D SOCK_SEQPACKET && sk->sk_type !=3D SOCK_RAW) {
+		if (sk->sk_type !=3D SOCK_SEQPACKET && sk->sk_type !=3D SOCK_STREAM
+				&& sk->sk_type !=3D SOCK_RAW) {
 			err =3D -EINVAL;
 			break;
 		}
@@ -2007,7 +2018,8 @@ static int l2cap_sock_getsockopt(struct socket *s=
ock, int level, int optname, ch
=20
 	switch (optname) {
 	case BT_SECURITY:
-		if (sk->sk_type !=3D SOCK_SEQPACKET && sk->sk_type !=3D SOCK_RAW) {
+		if (sk->sk_type !=3D SOCK_SEQPACKET && sk->sk_type !=3D SOCK_STREAM
+				&& sk->sk_type !=3D SOCK_RAW) {
 			err =3D -EINVAL;
 			break;
 		}
@@ -2314,7 +2326,7 @@ static int l2cap_build_conf_req(struct sock *sk, =
void *data)
 {
 	struct l2cap_pinfo *pi =3D l2cap_pi(sk);
 	struct l2cap_conf_req *req =3D data;
-	struct l2cap_conf_rfc rfc =3D { .mode =3D L2CAP_MODE_BASIC };
+	struct l2cap_conf_rfc rfc =3D { .mode =3D pi->mode };
 	void *ptr =3D req->data;
=20
 	BT_DBG("sk %p", sk);
@@ -3997,7 +4009,7 @@ static int l2cap_disconn_cfm(struct hci_conn *hco=
n, u8 reason)
=20
 static inline void l2cap_check_encryption(struct sock *sk, u8 encrypt)
 {
-	if (sk->sk_type !=3D SOCK_SEQPACKET)
+	if (sk->sk_type !=3D SOCK_SEQPACKET && sk->sk_type !=3D SOCK_STREAM)
 		return;
=20
 	if (encrypt =3D=3D 0x00) {
--=20
1.6.6.1

