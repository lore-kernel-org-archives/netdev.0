From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [patch net-next 2/2] net/sched: fix filter flushing
Date: Mon, 22 May 2017 13:54:07 -0700
Message-ID: <CAM_iQpUj8C+Rt_Jm8J_DHXedHAg-_GaKUYgQwQ28hN-=zcB-5Q@mail.gmail.com>
References: <20170520130132.1626-1-jiri@resnulli.us> <20170520130132.1626-2-jiri@resnulli.us>
 <CAM_iQpWha6aCV3kOfCEFsBLNiC7LFTh=K=QaL17rH4=PUoeUmQ@mail.gmail.com>
 <20170521055416.GA1848@nanopsycho> <CAM_iQpVPuC-FQ3R4QNDCBWxrX5s7Q4bENxMU7+1LooCdHdMZhw@mail.gmail.com>
 <20170521191941.GA4278@nanopsycho>
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
Received: from mail-wm0-f47.google.com ([74.125.82.47]:38412 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761779AbdEVUy2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 16:54:28 -0400
Received: by mail-wm0-f47.google.com with SMTP id e127so6857279wmg.1
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 13:54:28 -0700 (PDT)
In-Reply-To: <20170521191941.GA4278@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 21, 2017 at 12:19 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>>You can't claim you really delete it as long as actions can still
>>see it and dump it.
>
> No, user just wants to delete all the filters. That is done. User does
> not care if the actual chain structure is there or not.
>

Hmm, so users see a chain with no filters... Fair enough.
