From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCHv2 net-next 2/4] caif: Bad assert triggering false positive.
Date: Tue,  6 Dec 2011 23:15:42 +0100
Message-ID: <1323209744-9718-2-git-send-email-sjur.brandeland@stericsson.com>
References: <1323209744-9718-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:62053 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754813Ab1LFWP4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 17:15:56 -0500
Received: by lagp5 with SMTP id p5so1832677lag.19
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2011 14:15:55 -0800 (PST)
In-Reply-To: <1323209744-9718-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ix bad assert on fragment size triggering false positive.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 net/caif/cfrfml.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/caif/cfrfml.c b/net/caif/cfrfml.c
index 81660f8..6dc75d4 100644
--- a/net/caif/cfrfml.c
+++ b/net/caif/cfrfml.c
@@ -190,7 +190,7 @@ out:
=20
 static int cfrfml_transmit_segment(struct cfrfml *rfml, struct cfpkt *=
pkt)
 {
-	caif_assert(cfpkt_getlen(pkt) < rfml->fragment_size);
+	caif_assert(cfpkt_getlen(pkt) < rfml->fragment_size + RFM_HEAD_SIZE);
=20
 	/* Add info for MUX-layer to route the packet out. */
 	cfpkt_info(pkt)->channel_id =3D rfml->serv.layer.id;
--=20
1.7.0.4
