From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 30/42] drivers/net/wireless/prism54: Adjust confusing if
 indentation
Date: Thu, 5 Aug 2010 22:26:04 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1008052225460.31692@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: "Luis R. Rodriguez" <mcgrof@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:57993 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934268Ab0HEU0H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Aug 2010 16:26:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

Indent the branch of an if.

The semantic match that finds this problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@r disable braces4@
position p1,p2;
statement S1,S2;
@@

(
if (...) { ... }
|
if (...) S1@p1 S2@p2
)

@script:python@
p1 << r.p1;
p2 << r.p2;
@@

if (p1[0].column == p2[0].column):
  cocci.print_main("branch",p1)
  cocci.print_secs("after",p2)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/wireless/prism54/isl_ioctl.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/prism54/isl_ioctl.c b/drivers/net/wireless/prism54/isl_ioctl.c
index 77cd65d..d97a2ca 100644
--- a/drivers/net/wireless/prism54/isl_ioctl.c
+++ b/drivers/net/wireless/prism54/isl_ioctl.c
@@ -3234,7 +3234,7 @@ prism54_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
 	switch (cmd) {
 		case PRISM54_HOSTAPD:
 		if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
+			return -EPERM;
 		ret = prism54_hostapd(ndev, &wrq->u.data);
 		return ret;
 	}
