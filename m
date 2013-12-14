From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH v2 5/9] drivers: net: Put prototype declaration for function
 sbni_probe() in sbni.c
Date: Sat, 14 Dec 2013 17:55:42 +0530
Message-ID: <dd984c99d43214c39b23f95e9a58f3a675147e69.1386911124.git.rashika.kheria@gmail.com>
References: <a610f6ee6bb992b91e43bdc851f3db62fc3decd5.1386911123.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Sebastian Andrzej Siewior <sebastian@breakpoint.cc>,
	Rashika Kheria <rashika.kheria@gmail.com>,
	Sachin Kamat <sachin.kamat@linaro.org>, netdev@vger.kernel.org,
	josh@joshtriplett.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <a610f6ee6bb992b91e43bdc851f3db62fc3decd5.1386911123.git.rashika.kheria@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch declares the prototype for the function sbni_probe() in file=
 sbni.c.

Thus, it also removes the following warning in wan/sbni.c:
drivers/net/wan/sbni.c:224:12: warning: no previous prototype for =E2=80=
=98sbni_probe=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
---

This revision fixes the following issues of the previous revision:
Incorrect fix

 drivers/net/wan/sbni.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wan/sbni.c b/drivers/net/wan/sbni.c
index 388ddf6..5061ffd 100644
--- a/drivers/net/wan/sbni.c
+++ b/drivers/net/wan/sbni.c
@@ -221,6 +221,7 @@ static void __init sbni_devsetup(struct net_device =
*dev)
 	dev->netdev_ops =3D &sbni_netdev_ops;
 }
=20
+int __init sbni_probe(int unit);
 int __init sbni_probe(int unit)
 {
 	struct net_device *dev;
--=20
1.7.9.5
