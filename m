From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 3/3] net: wireless: rt2x00: Staticize
 rt2x00queue_pause_queue_nocheck()
Date: Tue, 06 Aug 2013 17:36:03 +0900
Message-ID: <000801ce927f$fc7549d0$f55fdd70$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	'Ivo van Doorn' <IvDoorn@gmail.com>,
	'Gertjan van Wingerde' <gwingerde@gmail.com>,
	'Helmut Schaa' <helmut.schaa@googlemail.com>,
	Jingoo Han <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:35321 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753591Ab3HFIgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 04:36:05 -0400
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rt2x00queue_pause_queue_nocheck()is used only in this file.
Fix the following sparse warning:

drivers/net/wireless/rt2x00/rt2x00queue.c:939:6: warning: symbol 'rt2x00queue_pause_queue_nocheck' was not declared. Should it be
static?

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/wireless/rt2x00/rt2x00queue.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rt2x00/rt2x00queue.c b/drivers/net/wireless/rt2x00/rt2x00queue.c
index aa95c6c..6c8a33b 100644
--- a/drivers/net/wireless/rt2x00/rt2x00queue.c
+++ b/drivers/net/wireless/rt2x00/rt2x00queue.c
@@ -936,7 +936,7 @@ void rt2x00queue_index_inc(struct queue_entry *entry, enum queue_index index)
 	spin_unlock_irqrestore(&queue->index_lock, irqflags);
 }
 
-void rt2x00queue_pause_queue_nocheck(struct data_queue *queue)
+static void rt2x00queue_pause_queue_nocheck(struct data_queue *queue)
 {
 	switch (queue->qid) {
 	case QID_AC_VO:
-- 
1.7.10.4
