From: sjur.brandeland@stericsson.com
Subject: [net-next 05/11] caif-hsi: changed test on aggregation_timeout
Date: Mon, 25 Jun 2012 19:49:37 +0200
Message-ID: <1340646583-21059-6-git-send-email-sjur.brandeland@stericsson.com>
References: <1340646583-21059-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sjurbren@gmail.com,
	Kim Lilliestierna XX <kim.xx.lilliestierna@stericsson.com>,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:57421 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754394Ab2FYRuA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 13:50:00 -0400
Received: by bkcji2 with SMTP id ji2so3429750bkc.19
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2012 10:49:59 -0700 (PDT)
In-Reply-To: <1340646583-21059-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Kim Lilliestierna XX <kim.xx.lilliestierna@stericsson.com>

Aggregation_timeout is an unsigned long,
a test for less than zero can never become true,
compare with zero instead.

Signed-off-by: Kim Lilliestierna <kim.xx.lilliestierna@stericsson.com>
Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 drivers/net/caif/caif_hsi.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
index f81f61f..56cc941 100644
--- a/drivers/net/caif/caif_hsi.c
+++ b/drivers/net/caif/caif_hsi.c
@@ -115,7 +115,7 @@ static bool cfhsi_can_send_aggregate(struct cfhsi *=
cfhsi)
 {
 	int i;
=20
-	if (cfhsi->aggregation_timeout < 0)
+	if (cfhsi->aggregation_timeout =3D=3D 0)
 		return true;
=20
 	for (i =3D 0; i < CFHSI_PRIO_BEBK; ++i) {
--=20
1.7.5.4
