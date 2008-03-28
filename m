From: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Subject: [PATCH] SCTP: Remove an useless parameter from
Date: Fri, 28 Mar 2008 09:52:22 +0800
Message-ID: <47EC4F56.6000300@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	lksctp-dev <lksctp-developers@lists.sourceforge.net>,
	David Miller <davem@davemloft.net>
To: vladislav <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63273 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753921AbYC1BxE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 21:53:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vlad,
There is an useless parameter in sctp_cmd_hb_timer_update,
remove it.

Signed-off-by: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
---
 net/sctp/sm_sideeffect.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 28eb38e..5daeab5 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -593,7 +593,6 @@ static void sctp_cmd_t3_rtx_timers_stop(sctp_cmd_seq_t *cmds,
 
 /* Helper function to update the heartbeat timer. */
 static void sctp_cmd_hb_timer_update(sctp_cmd_seq_t *cmds,
-				     struct sctp_association *asoc,
 				     struct sctp_transport *t)
 {
 	/* Update the heartbeat timer.  */
@@ -1457,7 +1456,7 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
 
 		case SCTP_CMD_HB_TIMER_UPDATE:
 			t = cmd->obj.transport;
-			sctp_cmd_hb_timer_update(commands, asoc, t);
+			sctp_cmd_hb_timer_update(commands, t);
 			break;
 
 		case SCTP_CMD_HB_TIMERS_STOP:
-- 
1.5.3

-- 
Regards
Gui Jianfeng

