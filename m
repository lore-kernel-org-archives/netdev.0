From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH mmots] net: static declaration of net_secret_init() follows
 non-static
Date: Mon, 7 Oct 2013 14:16:55 +0300
Message-ID: <20131007111655.GC2460@swordfish.minsk.epam.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46ix secure_seq build error

net/core/secure_seq.c:17:13: error: static declaration of =E2=80=98net_=
secret_init=E2=80=99 follows
non-static declaration
 static void net_secret_init(void)

In file included from net/core/secure_seq.c:11:0:
include/net/secure_seq.h:6:6: note: previous declaration of =E2=80=98ne=
t_secret_init=E2=80=99 was
here
 void net_secret_init(void);

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

---

 include/net/secure_seq.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/net/secure_seq.h b/include/net/secure_seq.h
index 52c1a90..f257486 100644
--- a/include/net/secure_seq.h
+++ b/include/net/secure_seq.h
@@ -3,7 +3,6 @@
=20
 #include <linux/types.h>
=20
-void net_secret_init(void);
 __u32 secure_ip_id(__be32 daddr);
 __u32 secure_ipv6_id(const __be32 daddr[4]);
 u32 secure_ipv4_port_ephemeral(__be32 saddr, __be32 daddr, __be16 dpor=
t);
