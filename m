From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next 1/1] net sched qdisc: pass netlink message flags
 in event notification
Date: Mon, 30 Oct 2017 12:23:42 -0700
Message-ID: <CAM_iQpXh0sD9uFYmxkc70Bo_ABxNOh4REU3suJUnpP-rDLmdfQ@mail.gmail.com>
References: <1509054014-23254-1-git-send-email-mrv@mojatatu.com>
 <CAM_iQpWC=JJDBnxPTmkSjqhBGqQakoWbTuBxnLSETHo7+mQvcA@mail.gmail.com>
 <85mv4atyk6.fsf@mojatatu.com> <CAM_iQpXm8CevNhWQV-MAP1FmN1aTy4m1tknviMphk-mR=t1=7Q@mail.gmail.com>
 <85o9ooo6g0.fsf@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>
To: Roman Mashak <mrv@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:44298 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932708AbdJ3TYD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 15:24:03 -0400
Received: by mail-pf0-f181.google.com with SMTP id x7so11799498pfa.1
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 12:24:03 -0700 (PDT)
In-Reply-To: <85o9ooo6g0.fsf@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 30, 2017 at 11:07 AM, Roman Mashak <mrv@mojatatu.com> wrote:
> Cong Wang <xiyou.wangcong@gmail.com> writes:
>
>> On Sat, Oct 28, 2017 at 8:36 PM, Roman Mashak <mrv@mojatatu.com> wrote:
>>> Cong Wang <xiyou.wangcong@gmail.com> writes:
>>
>> Hmm, I thought you use RTM_NEWQDISC+RTM_DELQDISC to
>> determine it is replacement, no?
>
> Create is RTM_NEWQDISC and NLM_F_EXCL|NLM_F_CREATE, replacement is
> RTM_NEWQDISC and NLM_F_REPLACE in netlink flags.

Is there any reason we can't use RTM_NEWQDISC+RTM_DELQDISC
rather than NLM_F_REPLACE to determine it is replacement?

Note, RTM_NEWQDISC+RTM_DELQDISC are put in a same
message not two.
