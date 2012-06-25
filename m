From: sjur.brandeland@stericsson.com
Subject: [net-next 01/11] caif: Remove unused pointer and code
Date: Mon, 25 Jun 2012 19:49:33 +0200
Message-ID: <1340646583-21059-2-git-send-email-sjur.brandeland@stericsson.com>
References: <1340646583-21059-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sjurbren@gmail.com,
	Kim Lilliestierna XX <kim.xx.lilliestierna@stericsson.com>,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:58023 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753667Ab2FYRtx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 13:49:53 -0400
Received: by lbbgm6 with SMTP id gm6so6807294lbb.19
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2012 10:49:52 -0700 (PDT)
In-Reply-To: <1340646583-21059-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Kim Lilliestierna XX <kim.xx.lilliestierna@stericsson.com>

Removed surplus call to caif_device_list() in caif_dev.c

Signed-off-by: Kim Lilliestierna <kim.xx.lilliestierna@stericsson.com>
Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 net/caif/caif_dev.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index aa6f716..92c9397 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -91,11 +91,8 @@ static int caifd_refcnt_read(struct caif_device_entr=
y *e)
 /* Allocate new CAIF device. */
 static struct caif_device_entry *caif_device_alloc(struct net_device *=
dev)
 {
-	struct caif_device_entry_list *caifdevs;
 	struct caif_device_entry *caifd;
=20
-	caifdevs =3D caif_device_list(dev_net(dev));
-
 	caifd =3D kzalloc(sizeof(*caifd), GFP_KERNEL);
 	if (!caifd)
 		return NULL;
--=20
1.7.5.4
