From: Roman Mashak <mrv@mojatatu.com>
Subject: Re: [PATCH net-next 1/1] net sched actions: rename act_get_notify() to tcf_get_notify()
Date: Wed, 05 Jul 2017 17:13:32 -0400
Message-ID: <85wp7mfuyr.fsf@mojatatu.com>
References: <1499283238-2551-1-git-send-email-mrv@mojatatu.com>
        <20170705203146.GA8974@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35032 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752431AbdGEVNh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 17:13:37 -0400
Received: by mail-it0-f66.google.com with SMTP id v193so15895050itc.2
        for <netdev@vger.kernel.org>; Wed, 05 Jul 2017 14:13:37 -0700 (PDT)
In-Reply-To: <20170705203146.GA8974@nanopsycho> (Jiri Pirko's message of "Wed,
        5 Jul 2017 22:31:46 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jiri@resnulli.us> writes:

> Wed, Jul 05, 2017 at 09:33:58PM CEST, mrv@mojatatu.com wrote:
>>Make name consistent with other TC event notification routines.
>>
>>Signed-off-by: Roman Mashak <mrv@mojatatu.com>
>>---
>> net/sched/act_api.c | 4 ++--
>> 1 file changed, 2 insertions(+), 2 deletions(-)
>>
>>diff --git a/net/sched/act_api.c b/net/sched/act_api.c
>>index aed6cf2..f2e9ed3 100644
>>--- a/net/sched/act_api.c
>>+++ b/net/sched/act_api.c
>>@@ -835,7 +835,7 @@ static int tca_get_fill(struct sk_buff *skb, struct list_head *actions,
>> }
>> 
>> static int
>>-act_get_notify(struct net *net, u32 portid, struct nlmsghdr *n,
>>+tcf_get_notify(struct net *net, u32 portid, struct nlmsghdr *n,
>
> Rather call it "tcf_action_get_notify"

We already have tcf_add_notify() and tcf_del_notify() as a common style.

>
> + net-next is closed if I'm not mistaken
