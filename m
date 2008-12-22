From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 21/27] drivers/net/wan: fix sparse warning: make symbol static
Date: Mon, 22 Dec 2008 20:18:04 +0100
Message-ID: <20081222191804.11807.55143.stgit@vmbox.hanneseder.net>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f21.google.com ([209.85.218.21]:50184 "EHLO
	mail-bw0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755981AbYLVTSK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2008 14:18:10 -0500
In-Reply-To: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix this sparse warning:

  drivers/net/wan/x25_asy.c:623:5: warning: symbol 'x25_asy_esc' was not declared. Should it be static?

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/net/wan/x25_asy.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wan/x25_asy.c b/drivers/net/wan/x25_asy.c
index 472bd0e..e6e2ce3 100644
--- a/drivers/net/wan/x25_asy.c
+++ b/drivers/net/wan/x25_asy.c
@@ -620,7 +620,7 @@ static struct net_device_stats *x25_asy_get_stats(struct net_device *dev)
   *			STANDARD X.25 ENCAPSULATION		  	 *
   ************************************************************************/
 
-int x25_asy_esc(unsigned char *s, unsigned char *d, int len)
+static int x25_asy_esc(unsigned char *s, unsigned char *d, int len)
 {
 	unsigned char *ptr = d;
 	unsigned char c;

