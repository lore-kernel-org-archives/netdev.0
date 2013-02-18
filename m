From: Stratos Karafotis <stratosk@semaphore.gr>
Subject: [PATCH linux-next] net: ipv6: Fix compiler warning
Date: Mon, 18 Feb 2013 22:38:42 +0200
Message-ID: <51229152.8010007@semaphore.gr>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46ix the following compiler warning (also a checkpatch error):

net/ipv6/xfrm6_mode_tunnel.c: In function =91xfrm6_mode_tunnel_input=92=
:
net/ipv6/xfrm6_mode_tunnel.c:72:2: warning: suggest parentheses around
assignment used as truth value [-Wparentheses]

Signed-off-by: Stratos Karafotis <stratosk@semaphore.gr>
---
 net/ipv6/xfrm6_mode_tunnel.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/xfrm6_mode_tunnel.c b/net/ipv6/xfrm6_mode_tunnel.=
c
index 93c41a8..9bf6a74 100644
--- a/net/ipv6/xfrm6_mode_tunnel.c
+++ b/net/ipv6/xfrm6_mode_tunnel.c
@@ -69,7 +69,8 @@ static int xfrm6_mode_tunnel_input(struct xfrm_state =
*x, struct sk_buff *skb)
 	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
 		goto out;
=20
-	if (err =3D skb_unclone(skb, GFP_ATOMIC))
+	err =3D skb_unclone(skb, GFP_ATOMIC);
+	if (err)
 		goto out;
=20
 	if (x->props.flags & XFRM_STATE_DECAP_DSCP)
--=20
1.8.1.2
