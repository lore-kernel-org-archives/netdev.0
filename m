From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 1/1] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Mon, 17 Apr 2017 10:02:30 -0400
Message-ID: <7a49a797-d9cb-37c1-e46b-bec6888539b9@mojatatu.com>
References: <1492346070-6002-1-git-send-email-jhs@emojatatu.com>
 <20170417081936.GA1892@nanopsycho.orion>
 <dfc1485f-7d7e-f52e-f62e-273063a59abc@mojatatu.com>
 <1492434659.10587.90.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, davem@davemloft.net,
        netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:36588 "EHLO
        mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751171AbdDQOCg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 10:02:36 -0400
Received: by mail-io0-f178.google.com with SMTP id o22so30594829iod.3
        for <netdev@vger.kernel.org>; Mon, 17 Apr 2017 07:02:36 -0700 (PDT)
In-Reply-To: <1492434659.10587.90.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-17 09:10 AM, Eric Dumazet wrote:

[..]
>
> We can not assume user programs properly cleared the paddings anyway.
>
> Using them for 'new features' is risky, since it might break programs.
>
> So the safe way is using new attributes really.

Since we agreed to have longer discussions on uapis
when we met I'd like to digress:
Can we talk about what it means to define pads in data
structures and then never using them?
As an example, no-one is setting these fields anywhere on any
app i know of. Would a union not be good enough for new name
vs old name? old binaries should continue to work.
Breakage with any app during compile should be fixable
within the breaking app (since whoever it is would have source).
Maybe by breaking some weird app we can experiment on finding
out.

My contention is that it is not nice to continue to define uapi
pads and  then say they cant be used ever.

cheers,
jamal
