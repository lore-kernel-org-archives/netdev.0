From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 0/22]: tc action cleanups
Date: Mon, 10 Jan 2005 20:37:30 +0100
Message-ID: <41E2D97A.1060400@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Jamal,

following are the reorganized tc action cleanup patches with some
additional fixes. Please review and comment, I would like to ask
Dave to pull them in soon so I don't get more clashes.

bk-tree is at: bk://212.42.230.204/net-2.6-sched

Patrick McHardy:
  o [PKT_SCHED]: Don't export ing_filter
  o [PKT_SCHED]: act_api.c: sync multi action order processing
  o [PKT_SCHED]: act_api.c: push memory allocation to tcf_action_get_1
  o [PKT_SCHED]: act_api.c: remove module loading from get/delete operations
  o [PKT_SCHED]: ipt action: fix module refcnt underflow/mem leaks in 
tcf_ipt_cleanup
  o [PKT_SCHED]: tc actions: remove unnecessary locking for refcnt changes
  o [PKT_SCHED]: ipt action: fix missing unlock on error path
  o [PKT_SCHED]: police action: fix multiple bugs in init path
  o [PKT_SCHED]: pedit action: fix multiple bugs in init path
  o [PKT_SCHED]: mirred action: fix multiple bugs in init path
  o [PKT_SCHED]: ipt action: fix multiple bugs in init path
  o [PKT_SCHED]: gact action: fix multiple bugs in init path
  o [PKT_SCHED]: tc actions: remove checks for impossible conditions
  o [PKT_SCHED]: tc actions: whitespace and coding style cleanup
  o [PKT_SCHED]: act_api.c: clean up init path, propagate errors properly
  o [RTNETLINK]: Use rtattr_strcmp where appropriate
  o [RTNETLINK]: Add rtattr_strlcpy, use it where appropriate
  o [PKT_SCHED]: act_api.c: remove unnecessary initializations
  o [PKT_SCHED]: act_api.c: remove checks for impossible conditions
  o [PKT_SCHED]: act_api.c: use consistent comparision style
  o [PKT_SCHED]: act_api.c: whitespace and coding style cleanup

Rusty Russell:
  o [PKT_SCHED]: Restore net/sched/ipt.c After iptables Kmod Cleanup
