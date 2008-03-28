From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 4/4] [SCTP]: Remove an unused parameter from sctp_cmd_hb_timer_update
Date: Fri, 28 Mar 2008 10:56:20 -0400
Message-ID: <1206716180-16573-5-git-send-email-vladislav.yasevich@hp.com>
References: <1206716180-16573-1-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	Gui Jianfeng <guijianfeng@cn.fujitsu.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:21943 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756510AbYC1O43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 10:56:29 -0400
In-Reply-To: <1206716180-16573-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gui Jianfeng <guijianfeng@cn.fujitsu.com>

The 'asoc' parameter to sctp_cmd_hb_timer_update() is unused, and
we can remove it.

Signed-off-by: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/sm_sideeffect.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 38de7bd..0f82684 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -589,7 +589,6 @@ static void sctp_cmd_t3_rtx_timers_stop(sctp_cmd_seq_t *cmds,
 
 /* Helper function to update the heartbeat timer. */
 static void sctp_cmd_hb_timer_update(sctp_cmd_seq_t *cmds,
-				     struct sctp_association *asoc,
 				     struct sctp_transport *t)
 {
 	/* Update the heartbeat timer.  */
@@ -1451,7 +1450,7 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
 
 		case SCTP_CMD_HB_TIMER_UPDATE:
 			t = cmd->obj.transport;
-			sctp_cmd_hb_timer_update(commands, asoc, t);
+			sctp_cmd_hb_timer_update(commands, t);
 			break;
 
 		case SCTP_CMD_HB_TIMERS_STOP:
-- 
1.5.3.5

