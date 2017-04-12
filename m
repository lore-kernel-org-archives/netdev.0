From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH v2 net-next] net: stmmac: add drop transmit status feature
Date: Wed, 12 Apr 2017 16:43:38 +0100
Message-ID: <47a1103e-74da-91be-eb9d-ad772b6a2e1f@synopsys.com>
References: <efbda38a-2146-06b2-9151-19294c654d28@synopsys.com>
 <20170412.105101.58827766857310782.davem@davemloft.net>
 <13ddd2d8-c2a4-4983-a9af-8e34f605374c@synopsys.com>
 <20170412.112825.1170167825508436176.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <andrew@lunn.ch>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.60.111]:41630 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752413AbdDLPoa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 11:44:30 -0400
In-Reply-To: <20170412.112825.1170167825508436176.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Às 4:28 PM de 4/12/2017, David Miller escreveu:
> From: Joao Pinto <Joao.Pinto@synopsys.com>
> Date: Wed, 12 Apr 2017 16:13:33 +0100
> 
>> Às 3:51 PM de 4/12/2017, David Miller escreveu:
>>> You cannot develop performance based features and only test their
>>> impact on FPGA when almost all users are on real silicon.
>>>
>>> And this requirement is absolutely non-negotiable.
>>>
>>> You must test the impact on real silicon otherwise your performance
>>> numbers, which are required to be provided in the commit message
>>> for any "performance" feature or change, are completely useless.
>>
>> Next time I won't mention anything about performance, honestly. "Drop TX Status"
>> is just an IP Core feature that can or not be used, it is up to the driver user.
> 
> Being dishonest about why a change might be desirable doesn't help things, in fact
> now that you've stated this intent in the future, people know to be suspucious of
> your changes.

Dishonest? I just sent the patch adding a optional configuration that can boost
performance in applications where timestapping is not an issue. You can request
more info in stmmac.txt, but calling me dishonest is a bit out of line.

I perfectly accept if you feel that the patch is not useful, that's fine.

> 
> I seriously don't think you realize the ramifications of what you just said right
> there.

No, I don't see honestly. I just said that I am a developer that has an interest
in the success of stmmac, but I don't want to steal maintenance seats :).

> 
> Everything here is about trust, and if you create a situation where you can't be
> trusted then the process of doing upstream development will be extremely difficult
> and time consuming for you.

Agree, trust is fundamental. I never gave reasons not to be trusted, in fact I
have a good relation with some of the stmmac developers and in other subsystems,
so I don't see the point of your observations.

> 
> Thanks.
> 

Joao
