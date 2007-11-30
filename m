From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH] remove extra memset from dn_fib_check_nh
Date: Fri, 30 Nov 2007 18:54:01 +0300
Message-ID: <20071130155401.GA10051@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devel@openvz.org, netdev@vger.kernel.org, davem@davemloft.net
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:63914 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932664AbXK3PxP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2007 10:53:15 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PATCH] remove extra memset from dn_fib_check_nh

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/decnet/dn_fib.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/decnet/dn_fib.c b/net/decnet/dn_fib.c
index 5413e1b..4aa9a42 100644
--- a/net/decnet/dn_fib.c
+++ b/net/decnet/dn_fib.c
@@ -203,8 +203,6 @@ static int dn_fib_check_nh(const struct rtmsg *r, struct dn_fib_info *fi, struct
 		struct flowi fl;
 		struct dn_fib_res res;
 
-		memset(&fl, 0, sizeof(fl));
-
 		if (nh->nh_flags&RTNH_F_ONLINK) {
 			struct net_device *dev;
 
-- 
1.5.3.rc5

