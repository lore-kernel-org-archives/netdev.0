From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH] sctp: user perfect name for Delayed SACK Timer option
Date: Wed, 19 Jan 2011 15:33:30 +0800
Message-ID: <4D3693CA.40508@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: David Miller <davem@davemloft.net>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	=?UTF-8?B?6a2P5YuH5Yab?= <yjwei@cn.fujitsu.com>,
	Network-Maillist <netdev@vger.kernel.org>,
	SCTP-Mailli
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57876 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751332Ab1ASHhA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 02:37:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The option name of Delayed SACK Timer should be SCTP_DELAYED_SACK,
not SCTP_DELAYED_ACK.

Reference:
8.1.19.  Get or Set Delayed SACK Timer (SCTP_DELAYED_SACK)
=EF=BC=88http://tools.ietf.org/html/draft-ietf-tsvwg-sctpsocket-25)


Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 include/net/sctp/user.h |    2 +-
 net/sctp/socket.c       |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/sctp/user.h b/include/net/sctp/user.h
index 2b2769c..74e10d6 100644
--- a/include/net/sctp/user.h
+++ b/include/net/sctp/user.h
@@ -77,7 +77,7 @@ typedef __s32 sctp_assoc_t;
 #define SCTP_STATUS	14
 #define SCTP_GET_PEER_ADDR_INFO	15
 #define SCTP_DELAYED_ACK_TIME	16
-#define SCTP_DELAYED_ACK SCTP_DELAYED_ACK_TIME
+#define SCTP_DELAYED_SACK SCTP_DELAYED_ACK_TIME
 #define SCTP_CONTEXT	17
 #define SCTP_FRAGMENT_INTERLEAVE	18
 #define SCTP_PARTIAL_DELIVERY_POINT	19 /* Set/Get partial delivery poi=
nt */
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index a09b0dd..8e02550 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3428,7 +3428,7 @@ SCTP_STATIC int sctp_setsockopt(struct sock *sk, =
int level, int optname,
 		retval =3D sctp_setsockopt_peer_addr_params(sk, optval, optlen);
 		break;
=20
-	case SCTP_DELAYED_ACK:
+	case SCTP_DELAYED_SACK:
 		retval =3D sctp_setsockopt_delayed_ack(sk, optval, optlen);
 		break;
 	case SCTP_PARTIAL_DELIVERY_POINT:
@@ -5333,7 +5333,7 @@ SCTP_STATIC int sctp_getsockopt(struct sock *sk, =
int level, int optname,
 		retval =3D sctp_getsockopt_peer_addr_params(sk, len, optval,
 							  optlen);
 		break;
-	case SCTP_DELAYED_ACK:
+	case SCTP_DELAYED_SACK:
 		retval =3D sctp_getsockopt_delayed_ack(sk, len, optval,
 							  optlen);
 		break;
--=20
1.6.3.3
