From: Paul Moore <paul.moore@hp.com>
Subject: [PATCH] tun: Remove a dead line of code
Date: Tue, 07 Jul 2009 14:11:33 -0400
Message-ID: <20090707181133.8021.9712.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:16593 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752558AbZGGSLg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2009 14:11:36 -0400
Received: from g1t0038.austin.hp.com (g1t0038.austin.hp.com [16.236.32.44])
	by g4t0017.houston.hp.com (Postfix) with ESMTP id 2885338472
	for <netdev@vger.kernel.org>; Tue,  7 Jul 2009 18:11:36 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove an unnecessary assignment.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---

 drivers/net/tun.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 027f7ab..4a0db7a 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -997,7 +997,6 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 				goto err_free_sk;
 		}
 
-		err = -EINVAL;
 		err = register_netdevice(tun->dev);
 		if (err < 0)
 			goto err_free_sk;

