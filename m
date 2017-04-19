From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 1/2 v2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Wed, 19 Apr 2017 07:06:12 -0400
Message-ID: <9cefb53c-d275-471e-aa90-15bc8c92692d@mojatatu.com>
References: <1492564489-28854-1-git-send-email-jhs@emojatatu.com>
 <1492566545.10587.159.camel@edumazet-glaptop3.roam.corp.google.com>
 <b00c5e30-47e9-0e71-7980-b57740ac09be@mojatatu.com>
 <CAM_iQpVbgNB53L-fVwtSfJSfBmSDua4EttqoHALzNiuuJOUT3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@resnulli.us>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:36515 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1762614AbdDSLGU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 07:06:20 -0400
Received: by mail-it0-f67.google.com with SMTP id a140so1936839ita.3
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 04:06:15 -0700 (PDT)
In-Reply-To: <CAM_iQpVbgNB53L-fVwtSfJSfBmSDua4EttqoHALzNiuuJOUT3A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-19 02:12 AM, Cong Wang wrote:
> On Tue, Apr 18, 2017 at 7:32 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> On 17-04-18 09:49 PM, Eric Dumazet wrote:

>> With this change I ask the kernel to fit as many actions as
>> possible in the 32K (all these 128 will fit in one batch).
>> Then it has to tell user space how many are in that batch
>> using TCAA_ACT_COUNT attribute.
>>
>> Make sense?
>
> Hmm? How do tc filters do dumping? There is no max and no
> COUNT attribute either, IIUC.
>

They dont have this hard coded 32 entries limit. So standard
dumping works fine. Note: count is a very speacial attribute to
make sure we can distinguish between old kernels which send
only 32 and new kernels which could send more.

cheers,
jamal
