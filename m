From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 05/13] net: Mark function as static in core/filter.c
Date: Sun, 9 Feb 2014 01:25:05 +0530
Message-ID: <b4fedb3d1984f8e1878015e12b7214c00a6588bb.1391888654.git.rashika.kheria@gmail.com>
References: <6f029c895035908595957fb16ab445c82793c77d.1391888654.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Rashika Kheria <rashika.kheria@gmail.com>,
	netdev@vger.kernel.org, josh@joshtriplett.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6f029c895035908595957fb16ab445c82793c77d.1391888654.git.rashika.kheria@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark function as static in core/filter.c because it is not used outside
this file.

This eliminates the following warning in core/filter.c:
net/core/filter.c:48:7: warning: no previous prototype for =E2=80=98bpf=
_internal_load_pointer_neg_helper=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
---
 net/core/filter.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index ad30d62..a022dad 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -44,7 +44,8 @@
  *
  * Exported for the bpf jit load helper.
  */
-void *bpf_internal_load_pointer_neg_helper(const struct sk_buff *skb, =
int k, unsigned int size)
+static void *bpf_internal_load_pointer_neg_helper(const struct sk_buff=
 *skb,
+						  int k, unsigned int size)
 {
 	u8 *ptr =3D NULL;
=20
--=20
1.7.9.5
