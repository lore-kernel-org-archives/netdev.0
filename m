From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 0/17]: tc action cleanup + fixes
Date: Thu, 30 Dec 2004 04:39:11 +0100
Message-ID: <41D3785F.3040909@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Jamal,

here is what I got so far, I'll continue tommorrow. Only compile
tested yet. Please review and comment.

Patrick McHardy:
   o [PKT_SCHED]: Disable broken override bits in pedit action
   o [PKT_SCHED]: Return proper error codes in tcf_pedit_init
   o [PKT_SCHED]: Remove checks for impossible conditions in pedit action
   o [PKT_SCHED]: Clean up pedit action
   o [PKT_SCHED]: Clean up tcf_ipt_init
   o [PKT_SCHED]: Fix missing unlock in ipt action error path
   o [PKT_SCHED]: Remove checks for impossible conditions in ipt action
   o [PKT_SCHED]: Clean up ipt action
   o [PKT_SCHED]: Return -EOPNOTSUPP if gact probability is requested 
but not compiled in
   o [PKT_SCHED]: Return proper error codes in tcf_gact_init
   o [PKT_SCHED]: Remove checks for impossible conditions in gact action
   o [PKT_SCHED: Clean up gact action
   o [PKT_SCHED]: Clean up act_api.c action init path, propagate errors 
properly
   o [PKT_SCHED]: Check TCA_ACT_KIND payload size _before_ copying it
   o [PKT_SCHED]: Remove checks for impossible conditions in act_api.c
   o [PKT_SCHED]: Consistent comparision style in act_api.c
   o [PKT_SCHED]: act_api.c whitespace cleanup
 

Regards
Patrick
