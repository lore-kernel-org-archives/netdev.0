From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 03/16] 9P: remove unnecessary break after return
Date: Mon, 14 Jul 2014 18:30:53 +0200
Message-ID: <1405355467-7350-4-git-send-email-fabf@skynet.be>
References: <1405355467-7350-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, joe@perches.com,
	Fabian Frederick <fabf@skynet.be>,
	Eric Van Hensbergen <ericvh@gmail.com>,
	Ron Minnich <rminnich@sandia.gov>,
	Latchesar Ionkov <lucho@ionkov.net>,
	v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay006.isp.belgacom.be ([195.238.6.172]:27168 "EHLO
	mailrelay006.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756551AbaGNQbz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 12:31:55 -0400
In-Reply-To: <1405355467-7350-1-git-send-email-fabf@skynet.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/9p/client.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/9p/client.c b/net/9p/client.c
index 0004cba..e86a9be 100644
--- a/net/9p/client.c
+++ b/net/9p/client.c
@@ -959,7 +959,6 @@ static int p9_client_version(struct p9_client *c)
 		break;
 	default:
 		return -EINVAL;
-		break;
 	}
 
 	if (IS_ERR(req))
-- 
1.8.4.5
