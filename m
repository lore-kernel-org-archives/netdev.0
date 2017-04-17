From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 1/1] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Mon, 17 Apr 2017 17:31:33 +0200
Message-ID: <20170417153133.GA1895@nanopsycho.orion>
References: <1492346070-6002-1-git-send-email-jhs@emojatatu.com>
 <20170417081936.GA1892@nanopsycho.orion>
 <dfc1485f-7d7e-f52e-f62e-273063a59abc@mojatatu.com>
 <1492434659.10587.90.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net,
        netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:35685 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932198AbdDQPbg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 11:31:36 -0400
Received: by mail-wr0-f193.google.com with SMTP id l44so20714581wrc.2
        for <netdev@vger.kernel.org>; Mon, 17 Apr 2017 08:31:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1492434659.10587.90.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Apr 17, 2017 at 03:10:59PM CEST, eric.dumazet@gmail.com wrote:
>On Mon, 2017-04-17 at 07:01 -0400, Jamal Hadi Salim wrote:
>
>> The name "pad" is ugly - but _we need to put these reserved spaces
>> to good use_. We cant keep declaring pads and say they should never
>> be used in the future.
>> We dont need more than 2-3 bits for the flags for example and i dont
>> see anyone dumping 64K actions in one message.
>> An attribute is a big waste of space. I cant change the name pad - 
>> perhaps a union with a new name? We had a similar discussion a while 
>> back on some netlink header, i just dont remember the details.
>> Suggestions?
>
>We can not assume user programs properly cleared the paddings anyway.
>
>Using them for 'new features' is risky, since it might break programs.
>
>So the safe way is using new attributes really.

Agreed.

Plus the argument that attributes are "a big waste" sounds to me really
silly. What is couple of bytes? Please do this properly, as it should
be done.


>
>
>
>
