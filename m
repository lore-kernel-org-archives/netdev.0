From: akpm@linux-foundation.org
Subject: [patch 1/4] misdn: indentation & braces disagree - add braces
Date: Fri, 09 Jan 2009 12:22:50 -0800
Message-ID: <200901092022.n09KMocF019893@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	ilpo.jarvinen@helsinki.fi
To: kkeil@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59113 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754837AbZAIUXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 15:23:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Nothing is broken because of this - currently.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
Cc: Karsten Keil <kkeil@suse.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/isdn/mISDN/dsp_cmx.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff -puN drivers/isdn/mISDN/dsp_cmx.c~misdn-indentation-braces-disagre=
e-add-braces drivers/isdn/mISDN/dsp_cmx.c
--- a/drivers/isdn/mISDN/dsp_cmx.c~misdn-indentation-braces-disagree-ad=
d-braces
+++ a/drivers/isdn/mISDN/dsp_cmx.c
@@ -1857,7 +1857,7 @@ dsp_cmx_hdlc(struct dsp *dsp, struct sk_
 		/* in case of hardware (echo) */
 		if (dsp->pcm_slot_tx >=3D 0)
 			return;
-		if (dsp->echo)
+		if (dsp->echo) {
 			nskb =3D skb_clone(skb, GFP_ATOMIC);
 			if (nskb) {
 				hh =3D mISDN_HEAD_P(nskb);
@@ -1866,6 +1866,7 @@ dsp_cmx_hdlc(struct dsp *dsp, struct sk_
 				skb_queue_tail(&dsp->sendq, nskb);
 				schedule_work(&dsp->workq);
 			}
+		}
 		return;
 	}
 	/* in case of hardware conference */
_
