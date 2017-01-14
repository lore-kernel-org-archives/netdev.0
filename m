From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] atm: remove an unnecessary loop
Date: Fri, 13 Jan 2017 16:41:53 -0800
Message-ID: <CAM_iQpUY4cQePzdvQ9QWUc5AyGxXsaJS1P+UNyEoARY97kKKRA@mail.gmail.com>
References: <CAM_iQpX2TipBW2Pm-OHRobfZaVoV9_D8Se8u9oKryt96SZFRkA@mail.gmail.com>
 <20170113132346.GA19220@electric-eye.fr.zoreil.com> <CAM_iQpUCVh9y8uhZ8Hj0mcjgfMGUQDvaEvSu5Wur1oVn+EZNGQ@mail.gmail.com>
 <20170114001519.GB6874@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Michal Hocko <mhocko@kernel.org>,
        Chas Williams <3chas3@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:32976 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750809AbdANAmP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 19:42:15 -0500
Received: by mail-qk0-f195.google.com with SMTP id 11so9304313qkl.0
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 16:42:14 -0800 (PST)
In-Reply-To: <20170114001519.GB6874@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 13, 2017 at 4:15 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Cong Wang <xiyou.wangcong@gmail.com> :
>> On Fri, Jan 13, 2017 at 5:23 AM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> [...]
>> > alloc_skb() does not need to be in the "while" loop.
>>
>> This is exactly what I describe in my changelog, don't know
>> why you want to repeat it...
>
> Because it is still hidden in a while loop.
>
> You turned the alloc from a two level deep "while" loop to a one level
> one. I want it at zero level. alloc_skb(..., GFP_KERNEL) fails ?
> So let it be done (see patch in other message).
>

Why I didn't remove all the loops is already stated in the later patch,
you said you read it? I doubt. ;)


> [...]
>> Please don't expect me to fix many things in one patch, let's
>> fix each of them separately, agreed?
>
> I am not convinced that several patches are needed to get the whole
> picture right.
>

My guideline for stable fixes is one patch fixes one problem, maybe
not suitable to you I think. Let's agree to disagree. ;)
