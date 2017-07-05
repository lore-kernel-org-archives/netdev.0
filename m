From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 1/1] net sched actions: rename act_get_notify()
 to tcf_get_notify()
Date: Wed, 5 Jul 2017 22:31:46 +0200
Message-ID: <20170705203146.GA8974@nanopsycho>
References: <1499283238-2551-1-git-send-email-mrv@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Roman Mashak <mrv@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:34880 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751907AbdGEUbt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 16:31:49 -0400
Received: by mail-wr0-f196.google.com with SMTP id z45so48205wrb.2
        for <netdev@vger.kernel.org>; Wed, 05 Jul 2017 13:31:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1499283238-2551-1-git-send-email-mrv@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jul 05, 2017 at 09:33:58PM CEST, mrv@mojatatu.com wrote:
>Make name consistent with other TC event notification routines.
>
>Signed-off-by: Roman Mashak <mrv@mojatatu.com>
>---
> net/sched/act_api.c | 4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
>
>diff --git a/net/sched/act_api.c b/net/sched/act_api.c
>index aed6cf2..f2e9ed3 100644
>--- a/net/sched/act_api.c
>+++ b/net/sched/act_api.c
>@@ -835,7 +835,7 @@ static int tca_get_fill(struct sk_buff *skb, struct list_head *actions,
> }
> 
> static int
>-act_get_notify(struct net *net, u32 portid, struct nlmsghdr *n,
>+tcf_get_notify(struct net *net, u32 portid, struct nlmsghdr *n,

Rather call it "tcf_action_get_notify"

+ net-next is closed if I'm not mistaken
