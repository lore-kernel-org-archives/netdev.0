From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [net-next PATCH v2 3/6] net sched: mirred action fix late binding
Date: Mon, 9 May 2016 21:37:05 -0700
Message-ID: <CAM_iQpUCuNs9dcqxoM8rhhhoyYChHEGeqqXhecBw7+nX+m_j+w@mail.gmail.com>
References: <1462728392-28489-1-git-send-email-jhs@emojatatu.com>
 <1462728392-28489-4-git-send-email-jhs@emojatatu.com> <CAM_iQpWjQsJTRVoE2nf4SxY=YF-0q4j6kDD8fJDLq3K=2QWwLw@mail.gmail.com>
 <573079DA.4020807@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f172.google.com ([209.85.161.172]:34665 "EHLO
	mail-yw0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750858AbcEJEhZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 00:37:25 -0400
Received: by mail-yw0-f172.google.com with SMTP id j74so1306713ywg.1
        for <netdev@vger.kernel.org>; Mon, 09 May 2016 21:37:25 -0700 (PDT)
In-Reply-To: <573079DA.4020807@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 9, 2016 at 4:51 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 16-05-08 11:19 PM, Cong Wang wrote:
>>
>> On Sun, May 8, 2016 at 10:26 AM, Jamal Hadi Salim <jhs@mojatatu.com>
>> wrote:
>>>
>>> -static int tcf_mirred_dump(struct sk_buff *skb, struct tc_action *a, int
>>> bind, int ref)
>>> +static int tcf_mirred_dump(struct sk_buff *skb, struct tc_action *a, int
>>> bind,
>>> +                          int ref)
>>>   {
>>>          unsigned char *b = skb_tail_pointer(skb);
>>>          struct tcf_mirred *m = a->priv;
>>
>>
>> Nit: this is irrelevant to the bug you fix.
>>
>
> It is (80 char) indentation fix. Dont think it deserves its own patch
> but it was annoying enough to include.

If you target this to net-next, I would not even mention it, but you
are targeting it for -stable... ;)
