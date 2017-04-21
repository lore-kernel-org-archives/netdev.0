From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v6 1/3] net sched actions: User proper root
 attribute table for actions
Date: Fri, 21 Apr 2017 15:08:09 +0200
Message-ID: <20170421130809.GB1874@nanopsycho.orion>
References: <1492772132-16559-1-git-send-email-jhs@emojatatu.com>
 <1492772132-16559-2-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:32809 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1161154AbdDUNIM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 09:08:12 -0400
Received: by mail-wr0-f193.google.com with SMTP id w50so7469939wrc.0
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 06:08:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1492772132-16559-2-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

subj: s/user/use/


Fri, Apr 21, 2017 at 12:55:30PM CEST, jhs@mojatatu.com wrote:
>From: Jamal Hadi Salim <jhs@mojatatu.com>
>
>Bug fix for an issue which has been around for about a decade.
>We got away with it because the enumeration was larger than needed.
>
>Fixes commit 7ba699c604ab ("[NET_SCHED]: Convert actions from rtnetlink to new netlink API")

^^^^^^^^^^^^^^^^^ this is incorrect format.

>
>Thanks to Jiri Pirko for spotting it.

Suggested-by: Jiri Pirko <jiri@mellanox.com>


>
>Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
>---
> net/sched/act_api.c | 4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
>
>diff --git a/net/sched/act_api.c b/net/sched/act_api.c
>index 82b1d48..9ce22b7 100644
>--- a/net/sched/act_api.c
>+++ b/net/sched/act_api.c
>@@ -997,7 +997,7 @@ static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n,
> 			 struct netlink_ext_ack *extack)
> {
> 	struct net *net = sock_net(skb->sk);
>-	struct nlattr *tca[TCA_ACT_MAX + 1];
>+	struct nlattr *tca[TCAA_MAX + 1];
> 	u32 portid = skb ? NETLINK_CB(skb).portid : 0;
> 	int ret = 0, ovr = 0;
> 
>@@ -1005,7 +1005,7 @@ static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n,
> 	    !netlink_capable(skb, CAP_NET_ADMIN))
> 		return -EPERM;
> 
>-	ret = nlmsg_parse(n, sizeof(struct tcamsg), tca, TCA_ACT_MAX, NULL,
>+	ret = nlmsg_parse(n, sizeof(struct tcamsg), tca, TCAA_MAX, NULL,
> 			  extack);
> 	if (ret < 0)
> 		return ret;
>-- 
>1.9.1
>
