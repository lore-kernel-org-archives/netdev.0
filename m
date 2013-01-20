From: Patrik Karlin <patrik.karlin@gmail.com>
Subject: [PATCH 2/5] drivers: atm: checkpatch.pl fixes removed all trailing whitespaces in eni.c
Date: Mon, 21 Jan 2013 00:12:52 +0100
Message-ID: <1358723575-8345-2-git-send-email-patrik.karlin@gmail.com>
References: <1358723575-8345-1-git-send-email-patrik.karlin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Patrik Karlin <patrik.karlin@gmail.com>
To: chas@cmf.nrl.navy.mil
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358723575-8345-1-git-send-email-patrik.karlin@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes all trailing whitespace's in eni.c
as sugested by checkpatch.pl

Signed-off-by: Patrik K=C3=A5rlin <patrik.karlin@gmail.com>
---
 drivers/atm/eni.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/atm/eni.c b/drivers/atm/eni.c
index 6ae0d89..1d5adc2 100644
--- a/drivers/atm/eni.c
+++ b/drivers/atm/eni.c
@@ -1,7 +1,7 @@
 /* drivers/atm/eni.c - Efficient Networks ENI155P device driver */
-=20
+
 /* Written 1995-2000 by Werner Almesberger, EPFL LRC/ICA */
-=20
+
=20
 #include <linux/module.h>
 #include <linux/kernel.h>
@@ -33,7 +33,7 @@
 #if !defined(__i386__) && !defined(__x86_64__)
 #ifndef ioremap_nocache
 #define ioremap_nocache(X, Y) ioremap(X, Y)
-#endif=20
+#endif
 #endif
=20
 /*
@@ -90,7 +90,7 @@ static void event_dump(void)
 #else
=20
=20
-/*=20
+/*
  * NULL pointer checking
  */
=20
@@ -112,7 +112,7 @@ static int ec =3D 0;
=20
 static void EVENT(const char *s, unsigned long a, unsigned long b)
 {
-	ev[ec] =3D s;=20
+	ev[ec] =3D s;
 	ev_a[ec] =3D a;
 	ev_b[ec] =3D b;
 	ec =3D (ec+1) % EV;
@@ -1800,7 +1800,7 @@ static void eni_do_release(struct atm_dev *dev)
 static int eni_start(struct atm_dev *dev)
 {
 	struct eni_dev *eni_dev;
-=09
+
 	void __iomem *buf;
 	unsigned long buffer_mem;
 	int error;
@@ -2148,7 +2148,7 @@ static int eni_proc_read(struct atm_dev *dev, lof=
f_t *pos, char *page)
 		    " (default)"
 #endif
 		    "\n", "");
-	if (!--left)=20
+	if (!--left)
 		return sprintf(page, "%4sBuffer multipliers: tx %d%%, rx %d%%\n",
 		    "", eni_dev->tx_mult, eni_dev->rx_mult);
 	for (i =3D 0; i < NR_CHAN; i++) {
--=20
1.7.10.4
