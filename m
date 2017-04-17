From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/1] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Mon, 17 Apr 2017 06:10:59 -0700
Message-ID: <1492434659.10587.90.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1492346070-6002-1-git-send-email-jhs@emojatatu.com>
         <20170417081936.GA1892@nanopsycho.orion>
         <dfc1485f-7d7e-f52e-f62e-273063a59abc@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, davem@davemloft.net,
        netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36063 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752238AbdDQNLB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 09:11:01 -0400
Received: by mail-pf0-f195.google.com with SMTP id i5so24788251pfc.3
        for <netdev@vger.kernel.org>; Mon, 17 Apr 2017 06:11:01 -0700 (PDT)
In-Reply-To: <dfc1485f-7d7e-f52e-f62e-273063a59abc@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-04-17 at 07:01 -0400, Jamal Hadi Salim wrote:

> The name "pad" is ugly - but _we need to put these reserved spaces
> to good use_. We cant keep declaring pads and say they should never
> be used in the future.
> We dont need more than 2-3 bits for the flags for example and i dont
> see anyone dumping 64K actions in one message.
> An attribute is a big waste of space. I cant change the name pad - 
> perhaps a union with a new name? We had a similar discussion a while 
> back on some netlink header, i just dont remember the details.
> Suggestions?

We can not assume user programs properly cleared the paddings anyway.

Using them for 'new features' is risky, since it might break programs.

So the safe way is using new attributes really.
