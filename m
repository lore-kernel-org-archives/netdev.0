From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v2 net 1/1] net sched actions: fix GETing actions
Date: Mon, 12 Sep 2016 16:51:03 -0400
Message-ID: <b773a674-cbb6-4b87-8a78-95648ab848ea@mojatatu.com>
References: <1473675692-8490-1-git-send-email-jhs@emojatatu.com>
 <CAM_iQpX3j_ejd1MjnaYkq0OL8B_gsN+SEoFk-8Srp+nWxKHzQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:36326 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755999AbcILUvN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 16:51:13 -0400
Received: by mail-oi0-f66.google.com with SMTP id o7so5341754oif.3
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 13:51:12 -0700 (PDT)
In-Reply-To: <CAM_iQpX3j_ejd1MjnaYkq0OL8B_gsN+SEoFk-8Srp+nWxKHzQg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-12 01:18 PM, Cong Wang wrote:
> On Mon, Sep 12, 2016 at 3:21 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:


>> +               if (ovr)
>> +                       a->tcfa_refcnt-=1;
>
> How about tcfa_bindcnt?

We dont touch it when mucking around only with actions (as is in
this case).


>> +       }
>> +}
>> +
>>  int tcf_action_init(struct net *net, struct nlattr *nla,
>>                                   struct nlattr *est, char *name, int ovr,
>>                                   int bind, struct list_head *actions)
>> @@ -612,8 +622,15 @@ int tcf_action_init(struct net *net, struct nlattr *nla,
>>                         goto err;
>>                 }
>>                 act->order = i;
>> +               if (ovr)
>
> Need to check this boolean? It looks like we need this for !ovr case too?
>

They are fine if they didnt exist.

I will fix the coding style issues and submit.

cheers,
jamal
