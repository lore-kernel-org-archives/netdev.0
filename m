From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [patch net v2 1/4] net/sched: Change tc_action refcnt and bindcnt
 to atomic
Date: Thu, 19 Oct 2017 20:00:18 -0700
Message-ID: <CAM_iQpVMLJjyuSgGHZycgzRz6KHusyTODOAMbw2dj7jTb7bbQQ@mail.gmail.com>
References: <1508152718-28726-1-git-send-email-chrism@mellanox.com>
 <1508152718-28726-2-git-send-email-chrism@mellanox.com> <CAM_iQpXA5y8nqCRAxy-9VJTSf3Z7g-6pL1PL1omcwkZn1apFUw@mail.gmail.com>
 <VI1PR0501MB21439CB952C540F903969648AB4C0@VI1PR0501MB2143.eurprd05.prod.outlook.com>
 <CAM_iQpWbfjCH0EFb8RYnOuZQtVtg-Mw-Kzv3GWq81qTVErN6hA@mail.gmail.com>
 <VI1PR0501MB21437552565B68DC71A7DEE1AB4D0@VI1PR0501MB2143.eurprd05.prod.outlook.com>
 <CAM_iQpVA2SQ4eFWEQxjQwmoxwQnQiLgREETKdQLoADWt_xD4Bg@mail.gmail.com> <b9444485-8e34-48ac-2b4f-abbd9c6d455f@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Chris Mi <chrism@mellanox.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Lucas Bates <lucasb@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>,
        David Miller <davem@davemloft.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:56531 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750960AbdJTDAj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 23:00:39 -0400
Received: by mail-pf0-f177.google.com with SMTP id b85so8922325pfj.13
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 20:00:39 -0700 (PDT)
In-Reply-To: <b9444485-8e34-48ac-2b4f-abbd9c6d455f@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 19, 2017 at 7:21 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 17-10-18 12:43 PM, Cong Wang wrote:
>>
>> On Tue, Oct 17, 2017 at 6:03 PM, Chris Mi <chrism@mellanox.com> wrote:
>>>>
>>>> -----Original Message-----
>
>
>>
>> You listed 3 problems, and you think they are 3 different ones, here
>> I argue problem 3 (using RCU callbacks) is the cause of problem 1
>> (refcnt not atomic). This is why I mentioned I have been thinking about
>> removing RCU callbacks, because it probably could fix all of them.
>>
>
> Cong,
> Given this is a known bug (the test case Chris presented crashes the
> kernel) - would it make sense to have a patch that goes to -net
> to fix this while your approach and discussion outcome goes into
> net-next?

I am not sure. Because Chris' patchset is large too and I don't think
it could fix all crashes, so it has little value to just apply them for -net.
