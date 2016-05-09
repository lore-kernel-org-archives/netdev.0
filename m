From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH v2 3/6] net sched: mirred action fix late binding
Date: Mon, 9 May 2016 07:51:54 -0400
Message-ID: <573079DA.4020807@mojatatu.com>
References: <1462728392-28489-1-git-send-email-jhs@emojatatu.com>
 <1462728392-28489-4-git-send-email-jhs@emojatatu.com>
 <CAM_iQpWjQsJTRVoE2nf4SxY=YF-0q4j6kDD8fJDLq3K=2QWwLw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:33795 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751242AbcEILv5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 07:51:57 -0400
Received: by mail-ig0-f170.google.com with SMTP id u5so14843464igk.1
        for <netdev@vger.kernel.org>; Mon, 09 May 2016 04:51:56 -0700 (PDT)
In-Reply-To: <CAM_iQpWjQsJTRVoE2nf4SxY=YF-0q4j6kDD8fJDLq3K=2QWwLw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-05-08 11:19 PM, Cong Wang wrote:
> On Sun, May 8, 2016 at 10:26 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> -static int tcf_mirred_dump(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
>> +static int tcf_mirred_dump(struct sk_buff *skb, struct tc_action *a, int bind,
>> +                          int ref)
>>   {
>>          unsigned char *b = skb_tail_pointer(skb);
>>          struct tcf_mirred *m = a->priv;
>
> Nit: this is irrelevant to the bug you fix.
>

It is (80 char) indentation fix. Dont think it deserves its own patch
but it was annoying enough to include.

cheers,
jamal
