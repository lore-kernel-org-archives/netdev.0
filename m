From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v4 1/2] net sched actions: Add support for user
 cookies
Date: Tue, 17 Jan 2017 12:03:12 -0500
Message-ID: <a1f74285-2901-f81d-5b79-934458a1f4cc@mojatatu.com>
References: <1484651509-27500-1-git-send-email-jhs@emojatatu.com>
 <1484651509-27500-2-git-send-email-jhs@emojatatu.com>
 <587E2747.9000207@iogearbox.net>
 <bead2dc5-87a2-2fca-d50d-871f28be1d5b@mojatatu.com>
 <587E4D16.8030708@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com, paulb@mellanox.com,
        john.fastabend@gmail.com, simon.horman@netronome.com,
        mrv@mojatatu.com, hadarh@mellanox.com, ogerlitz@mellanox.com,
        roid@mellanox.com, xiyou.wangcong@gmail.com
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:35370 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751057AbdAQREF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 12:04:05 -0500
Received: by mail-qt0-f193.google.com with SMTP id f4so22909340qte.2
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 09:03:14 -0800 (PST)
In-Reply-To: <587E4D16.8030708@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-17 11:57 AM, Daniel Borkmann wrote:
> On 01/17/2017 05:50 PM, Jamal Hadi Salim wrote:

>>>
>>>   struct tc_cookie cookie;
>>
>> Grep-ability.
>> I was worried about when the classifier adds its cookie it
>> would need to use something like cls_cookie etc.
>
> Given this cookie is just used for correlation in user space anyway
> and not processed any further by the kernel, I think we can well
> handle these very few spots, so would be better if the code is more
> maintainable instead.

act_cookie a better name?

cheers,
jamal
