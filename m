From: akpm@linux-foundation.org
Subject: [patch 3/4] isdn: mISDN, don't compile unused stuff
Date: Tue, 02 Feb 2010 14:43:46 -0800
Message-ID: <201002022243.o12MhkQJ019221@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jirislaby@gmail.com
To: isdn@linux-pingi.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:43754 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756894Ab0BBWoH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 17:44:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Slaby <jirislaby@gmail.com>

Remove these compiler warnings:

drivers/isdn/hardware/mISDN/w6692.c:534: warning: `setvolume' defined but not used
drivers/isdn/hardware/mISDN/w6692.c:561: warning: `enable_pots' defined but not used

by moving the functions inside #if 0 ...  #endif.  And an alternative is
to remove them completely if nobody has plans to use them.

Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
Cc: Karsten Keil <isdn@linux-pingi.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/isdn/hardware/mISDN/w6692.c |    2 ++
 1 file changed, 2 insertions(+)

diff -puN drivers/isdn/hardware/mISDN/w6692.c~isdn-misdn-dont-compile-unused-stuff drivers/isdn/hardware/mISDN/w6692.c
--- a/drivers/isdn/hardware/mISDN/w6692.c~isdn-misdn-dont-compile-unused-stuff
+++ a/drivers/isdn/hardware/mISDN/w6692.c
@@ -529,6 +529,7 @@ W6692_fill_Bfifo(struct w6692_ch *wch)
 	}
 }
 
+#if 0
 static int
 setvolume(struct w6692_ch *wch, int mic, struct sk_buff *skb)
 {
@@ -571,6 +572,7 @@ enable_pots(struct w6692_ch *wch)
 	WriteW6692(card, W_PCTL, card->pctl);
 	return 0;
 }
+#endif
 
 static int
 disable_pots(struct w6692_ch *wch)
_
