From: David Decotigny <decot@googlers.com>
Subject: [PATCH net-next v1 2/6] tg3: Remove IRQF_SAMPLE_RANDOM flag from internal tests
Date: Fri, 16 Dec 2011 10:19:45 -0800
Message-ID: <e5a227a4cf2782ff8f73886dbc5ca0fb8fad9c8a.1324059527.git.decot@googlers.com>
References: <cover.1324059527.git.decot@googlers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Javier Martinez Canillas <martinez.javier@gmail.com>,
	Robin Getz <rgetz@blackfin.uclinux.org>,
	Matt Mackall <mpm@selenic.com>,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
	David Decotigny <decot@googlers.com>
To: Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f202.google.com ([209.85.215.202]:40673 "EHLO
	mail-ey0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760348Ab1LPSZm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 13:25:42 -0500
Received: by eaad1 with SMTP id d1so96858eaa.1
        for <netdev@vger.kernel.org>; Fri, 16 Dec 2011 10:25:40 -0800 (PST)
In-Reply-To: <cover.1324059527.git.decot@googlers.com>
In-Reply-To: <cover.1324059527.git.decot@googlers.com>
References: <cover.1324059527.git.decot@googlers.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =C5=BBenczykowski <maze@google.com>

This complements commit ab392d2d6d4 ("Remove IRQF_SAMPLE_RANDOM flag
from network drivers"), removing IRQF_SAMPLE_RANDOM flag from internal
and self tests.

Tested: no visible regression on 1 actual host + ethtool -t passes.


Signed-off-by: David Decotigny <decot@googlers.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet=
/broadcom/tg3.c
index e04c4f9..a65b419 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -9387,7 +9387,7 @@ static int tg3_test_interrupt(struct tg3 *tp)
 	}
=20
 	err =3D request_irq(tnapi->irq_vec, tg3_test_isr,
-			  IRQF_SHARED | IRQF_SAMPLE_RANDOM, dev->name, tnapi);
+			  IRQF_SHARED, dev->name, tnapi);
 	if (err)
 		return err;
=20
--=20
1.7.3.1
