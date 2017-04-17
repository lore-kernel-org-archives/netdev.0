From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/1] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Mon, 17 Apr 2017 10:08:25 -0700
Message-ID: <1492448905.10587.109.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1492346070-6002-1-git-send-email-jhs@emojatatu.com>
         <20170417081936.GA1892@nanopsycho.orion>
         <dfc1485f-7d7e-f52e-f62e-273063a59abc@mojatatu.com>
         <1492434659.10587.90.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170417153133.GA1895@nanopsycho.orion>
         <0bd1e885-cdf3-60fc-783b-a075b777560b@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, davem@davemloft.net,
        netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35676 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753083AbdDQRI1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 13:08:27 -0400
Received: by mail-pg0-f68.google.com with SMTP id g2so28361049pge.2
        for <netdev@vger.kernel.org>; Mon, 17 Apr 2017 10:08:27 -0700 (PDT)
In-Reply-To: <0bd1e885-cdf3-60fc-783b-a075b777560b@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-04-17 at 12:46 -0400, Jamal Hadi Salim wrote:

> Of course it is trivial to add this as attributes and 32 bits
> for this case is not a big deal because it is done once. I want to talk
> about the pads instead ;-> What do you suggest we do with pads?

We do nothing with pads. Just leave them.

Or, you need something to make sure to not break old user applications.

Something like a version.
