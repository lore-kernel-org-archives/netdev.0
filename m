From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 01/13] net: Mark function as static in 9p/client.c
Date: Sun, 9 Feb 2014 01:17:21 +0530
Message-ID: <6f029c895035908595957fb16ab445c82793c77d.1391888654.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Van Hensbergen <ericvh@gmail.com>,
	Ron Minnich <rminnich@sandia.gov>,
	Latchesar Ionkov <lucho@ionkov.net>,
	"David S. Miller" <davem@davemloft.net>,
	v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org,
	josh@joshtriplett.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark function as static in net/9p/client.c because it is not used
outside this file.

This eliminates the following warning in net/9p/client.c:
net/9p/client.c:207:18: warning: no previous prototype for =E2=80=98p9_=
fcall_alloc=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
---
 net/9p/client.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/9p/client.c b/net/9p/client.c
index a5e4d2d..9186550 100644
--- a/net/9p/client.c
+++ b/net/9p/client.c
@@ -204,7 +204,7 @@ free_and_return:
 	return ret;
 }
=20
-struct p9_fcall *p9_fcall_alloc(int alloc_msize)
+static struct p9_fcall *p9_fcall_alloc(int alloc_msize)
 {
 	struct p9_fcall *fc;
 	fc =3D kmalloc(sizeof(struct p9_fcall) + alloc_msize, GFP_NOFS);
--=20
1.7.9.5
