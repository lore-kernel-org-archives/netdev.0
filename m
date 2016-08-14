From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net v3 5/5] net_sched: convert tcf_exts from list to
 pointer array
Date: Sat, 13 Aug 2016 22:03:24 -0700
Message-ID: <CAM_iQpUUb7Uwx35qcCWgf6_poawtNnVZUJwvGOUqFZ76YD22Ow@mail.gmail.com>
References: <1470962503-19682-1-git-send-email-xiyou.wangcong@gmail.com>
 <1470962503-19682-6-git-send-email-xiyou.wangcong@gmail.com> <70a062d7-5670-b71a-1ead-045a7b1426f5@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f47.google.com ([209.85.214.47]:37082 "EHLO
	mail-it0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752898AbcHNJCS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Aug 2016 05:02:18 -0400
Received: by mail-it0-f47.google.com with SMTP id f6so22138291ith.0
        for <netdev@vger.kernel.org>; Sun, 14 Aug 2016 02:02:18 -0700 (PDT)
In-Reply-To: <70a062d7-5670-b71a-1ead-045a7b1426f5@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 13, 2016 at 4:33 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>
> Just minor comment below:
>
> On 16-08-11 08:41 PM, Cong Wang wrote:
>
>
>> +static inline void
>> +tcf_exts_to_list(const struct tcf_exts *exts, struct list_head *actions)
>> +{
>
>
> to:
> static inline void tcf_exts_to_list(const struct tcf_exts *exts,
>                                     struct list_head *actions)

I don't disagree, just want to point out that other functions
in this header use similar indention. I am fine with either.

I will change this one, but you probably will need to change
the rest. ;)
