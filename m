From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 6/6] net_sched: cls_cgroup: remove unnecessary if
Date: Wed, 3 Dec 2014 14:18:15 +0100
Message-ID: <20141203131815.GF1860@nanopsycho.orion>
References: <1417539636-12710-1-git-send-email-jiri@resnulli.us>
 <1417539636-12710-7-git-send-email-jiri@resnulli.us>
 <547F0AFA.7090001@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:65027 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751149AbaLCNSS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 08:18:18 -0500
Received: by mail-wg0-f47.google.com with SMTP id n12so19704402wgh.6
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 05:18:17 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <547F0AFA.7090001@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Dec 03, 2014 at 02:07:06PM CET, jhs@mojatatu.com wrote:
>On 12/02/14 12:00, Jiri Pirko wrote:
>>since head->handle == handle (checked before), just assign handle.
>>
>>Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>---
>>  net/sched/cls_cgroup.c | 6 +-----
>>  1 file changed, 1 insertion(+), 5 deletions(-)
>>
>>diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
>>index d61a801..dbee65e 100644
>>--- a/net/sched/cls_cgroup.c
>>+++ b/net/sched/cls_cgroup.c
>>@@ -117,11 +117,7 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
>>  		return -ENOBUFS;
>>
>>  	tcf_exts_init(&new->exts, TCA_CGROUP_ACT, TCA_CGROUP_POLICE);
>>-	if (head)
>>-		new->handle = head->handle;
>>-	else
>>-		new->handle = handle;
>>-
>>+	new->handle = handle;
>
>
>Hrm. head could be NULL, no?

Sure it can. But that is not a problem. Not sure what you are trying to
point at...

>
>cheers,
>jamal
>
