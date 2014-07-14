From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 07/16] drop_monitor: remove unnecessary break after return
Date: Mon, 14 Jul 2014 18:30:57 +0200
Message-ID: <1405355467-7350-8-git-send-email-fabf@skynet.be>
References: <1405355467-7350-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, joe@perches.com,
	Fabian Frederick <fabf@skynet.be>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405355467-7350-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/core/drop_monitor.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
index e70301e..50f9a9d 100644
--- a/net/core/drop_monitor.c
+++ b/net/core/drop_monitor.c
@@ -289,10 +289,8 @@ static int net_dm_cmd_trace(struct sk_buff *skb,
 	switch (info->genlhdr->cmd) {
 	case NET_DM_CMD_START:
 		return set_all_monitor_traces(TRACE_ON);
-		break;
 	case NET_DM_CMD_STOP:
 		return set_all_monitor_traces(TRACE_OFF);
-		break;
 	}
 
 	return -ENOTSUPP;
-- 
1.8.4.5
