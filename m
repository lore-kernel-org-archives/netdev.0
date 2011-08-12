From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH][Trivial] net/wan/hdlc_ppp: remove dead goto
Date: Sat, 13 Aug 2011 01:39:43 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1108130138100.7387@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	trivial@kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jj@chaosbits.net>

We'll either hit one of the case labels or the default in the switch
and in all cases do we then 'goto out', so having 'goto out' right
after the switch is pointless as we can never hit it - remove it.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 drivers/net/wan/hdlc_ppp.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wan/hdlc_ppp.c b/drivers/net/wan/hdlc_ppp.c
index 055a918..5385876 100644
--- a/drivers/net/wan/hdlc_ppp.c
+++ b/drivers/net/wan/hdlc_ppp.c
@@ -547,7 +547,6 @@ static int ppp_rx(struct sk_buff *skb)
 		ppp_cp_event(dev, pid, RUC, 0, 0, len, cp);
 		goto out;
 	}
-	goto out;
 
 rx_error:
 	dev->stats.rx_errors++;
-- 
1.7.6


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.
