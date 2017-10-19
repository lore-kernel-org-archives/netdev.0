From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net v2 1/4] net/sched: Change tc_action refcnt and bindcnt
 to atomic
Date: Thu, 19 Oct 2017 10:21:18 -0400
Message-ID: <b9444485-8e34-48ac-2b4f-abbd9c6d455f@mojatatu.com>
References: <1508152718-28726-1-git-send-email-chrism@mellanox.com>
 <1508152718-28726-2-git-send-email-chrism@mellanox.com>
 <CAM_iQpXA5y8nqCRAxy-9VJTSf3Z7g-6pL1PL1omcwkZn1apFUw@mail.gmail.com>
 <VI1PR0501MB21439CB952C540F903969648AB4C0@VI1PR0501MB2143.eurprd05.prod.outlook.com>
 <CAM_iQpWbfjCH0EFb8RYnOuZQtVtg-Mw-Kzv3GWq81qTVErN6hA@mail.gmail.com>
 <VI1PR0501MB21437552565B68DC71A7DEE1AB4D0@VI1PR0501MB2143.eurprd05.prod.outlook.com>
 <CAM_iQpVA2SQ4eFWEQxjQwmoxwQnQiLgREETKdQLoADWt_xD4Bg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Lucas Bates <lucasb@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>,
        David Miller <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>,
        Chris Mi <chrism@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:47245 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753720AbdJSOVY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 10:21:24 -0400
Received: by mail-io0-f195.google.com with SMTP id h70so9987076ioi.4
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 07:21:24 -0700 (PDT)
In-Reply-To: <CAM_iQpVA2SQ4eFWEQxjQwmoxwQnQiLgREETKdQLoADWt_xD4Bg@mail.gmail.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-10-18 12:43 PM, Cong Wang wrote:
> On Tue, Oct 17, 2017 at 6:03 PM, Chris Mi <chrism@mellanox.com> wrote:
>>> -----Original Message-----

> 
> You listed 3 problems, and you think they are 3 different ones, here
> I argue problem 3 (using RCU callbacks) is the cause of problem 1
> (refcnt not atomic). This is why I mentioned I have been thinking about
> removing RCU callbacks, because it probably could fix all of them.
> 

Cong,
Given this is a known bug (the test case Chris presented crashes the
kernel) - would it make sense to have a patch that goes to -net
to fix this while your approach and discussion outcome goes into
net-next?

cheers,
jamal
