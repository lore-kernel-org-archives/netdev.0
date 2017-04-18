From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Case for reusing netlink PADs WAS(Re: [PATCH net-next 1/1] net
 sched actions: dump more than TCA_ACT_MAX_PRIO actions per batch
Date: Tue, 18 Apr 2017 07:19:46 -0700
Message-ID: <1492525186.10587.119.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1492346070-6002-1-git-send-email-jhs@emojatatu.com>
         <20170417081936.GA1892@nanopsycho.orion>
         <dfc1485f-7d7e-f52e-f62e-273063a59abc@mojatatu.com>
         <1492434659.10587.90.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170417153133.GA1895@nanopsycho.orion>
         <0bd1e885-cdf3-60fc-783b-a075b777560b@mojatatu.com>
         <1492448905.10587.109.camel@edumazet-glaptop3.roam.corp.google.com>
         <560eeb0b-7a34-484a-e4a1-c637b31eba59@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, davem@davemloft.net,
        netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35026 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751012AbdDROTu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 10:19:50 -0400
Received: by mail-pf0-f194.google.com with SMTP id a188so30866381pfa.2
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 07:19:50 -0700 (PDT)
In-Reply-To: <560eeb0b-7a34-484a-e4a1-c637b31eba59@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-04-18 at 08:48 -0400, Jamal Hadi Salim wrote:

> For our case it is _very sad_ that someone actually explicitly defined
> pads - in my opinion for no other purpose other than reuse and then
> we say we cant use them after.


Again, there is nothing you can do to avoid some pads _once_ they are
there.

Even if you leave the pad here, the 'wire protocol' will add padding
anyway ( NLMSG_ALIGN() and friends)
