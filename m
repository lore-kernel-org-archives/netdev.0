From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [patch net-next 2/2] net/sched: fix filter flushing
Date: Mon, 22 May 2017 22:39:37 -0700
Message-ID: <CAM_iQpWMW48oyOkoh7iRZEfwMTVy4t2ORKPU0fsKFmE8d5P0-Q@mail.gmail.com>
References: <20170520130132.1626-1-jiri@resnulli.us> <20170520130132.1626-2-jiri@resnulli.us>
 <CAM_iQpWha6aCV3kOfCEFsBLNiC7LFTh=K=QaL17rH4=PUoeUmQ@mail.gmail.com>
 <20170521055416.GA1848@nanopsycho> <CAM_iQpVPuC-FQ3R4QNDCBWxrX5s7Q4bENxMU7+1LooCdHdMZhw@mail.gmail.com>
 <20170521191941.GA4278@nanopsycho> <CAM_iQpUj8C+Rt_Jm8J_DHXedHAg-_GaKUYgQwQ28hN-=zcB-5Q@mail.gmail.com>
 <CAM_iQpVvsMhTVh7P5qL19dhbWitPPwN0FcFKW9F0eDJAkr5ViQ@mail.gmail.com> <20170523051713.GB1829@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Eric Dumazet <edumazet@google.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Simon Horman <simon.horman@netronome.com>, mlxsw@mellanox.com,
        Colin King <colin.king@canonical.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:35668 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758118AbdEWFj6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 01:39:58 -0400
Received: by mail-wm0-f42.google.com with SMTP id b84so12307754wmh.0
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 22:39:58 -0700 (PDT)
In-Reply-To: <20170523051713.GB1829@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 22, 2017 at 10:17 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Mon, May 22, 2017 at 11:04:58PM CEST, xiyou.wangcong@gmail.com wrote:
>>On Mon, May 22, 2017 at 1:54 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>> On Sun, May 21, 2017 at 12:19 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>>>You can't claim you really delete it as long as actions can still
>>>>>see it and dump it.
>>>>
>>>> No, user just wants to delete all the filters. That is done. User does
>>>> not care if the actual chain structure is there or not.
>>>>
>>>
>>> Hmm, so users see a chain with no filters... Fair enough.
>>
>>But since you remove the chain from the chain_list, it means
>>users could not add new filters to this chain after flushing? And
>
> No, in flush, I don't remove it from the list. That is not in the
> patch. Why would you think so?

Oh, I missed the minus before the first list_del()... I blame my
Web browser font.

Your patch looks good.
