From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 0/6]: assorted fixes
Date: Tue, 11 Jan 2005 22:46:14 +0100
Message-ID: <41E44926.5010701@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave,

following are a couple of assorted fixes: a mem leak, locking bugs in two
tc actions, your sch_api.c fix for holding the rtnl while loading modules
ported to act_api.c, and a bug in tcf_exts that prevents using 
actions/policers
without a rate estimator.

You can pull all changes from bk://212.42.230.204/net-2.6-sched

Regards
Patrick

Patrick McHardy:
  o [PKT_SCHED]: act_api.c: kill some exports
  o [PKT_SCHED]: tcf_exts: rate_tlv is optional
  o [PKT_SCHED]: act_api.c: drop rtnl for loading modules
  o [PKT_SCHED]: tc actions: disable bhs while lock is held in init path
  o [PKT_SCHED]: Fix memory leaks in cls_u32.c error path
  o [PKT_SCHED]: Use rtattr_parse_nested where appropriate
