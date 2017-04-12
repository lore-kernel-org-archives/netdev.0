From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: stmmac: add drop transmit status
 feature
Date: Wed, 12 Apr 2017 12:03:09 -0400 (EDT)
Message-ID: <20170412.120309.576259410886302201.davem@davemloft.net>
References: <13ddd2d8-c2a4-4983-a9af-8e34f605374c@synopsys.com>
        <20170412.112825.1170167825508436176.davem@davemloft.net>
        <47a1103e-74da-91be-eb9d-ad772b6a2e1f@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: andrew@lunn.ch, netdev@vger.kernel.org
To: Joao.Pinto@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47386 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754675AbdDLQDS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 12:03:18 -0400
In-Reply-To: <47a1103e-74da-91be-eb9d-ad772b6a2e1f@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joao Pinto <Joao.Pinto@synopsys.com>
Date: Wed, 12 Apr 2017 16:43:38 +0100

> Às 4:28 PM de 4/12/2017, David Miller escreveu:
>> From: Joao Pinto <Joao.Pinto@synopsys.com>
>> Date: Wed, 12 Apr 2017 16:13:33 +0100
>> 
>>> Às 3:51 PM de 4/12/2017, David Miller escreveu:
>>>> You cannot develop performance based features and only test their
>>>> impact on FPGA when almost all users are on real silicon.
>>>>
>>>> And this requirement is absolutely non-negotiable.
>>>>
>>>> You must test the impact on real silicon otherwise your performance
>>>> numbers, which are required to be provided in the commit message
>>>> for any "performance" feature or change, are completely useless.
>>>
>>> Next time I won't mention anything about performance, honestly. "Drop TX Status"
>>> is just an IP Core feature that can or not be used, it is up to the driver user.
>> 
>> Being dishonest about why a change might be desirable doesn't help things, in fact
>> now that you've stated this intent in the future, people know to be suspucious of
>> your changes.
> 
> Dishonest? I just sent the patch adding a optional configuration that can boost
> performance in applications where timestapping is not an issue. You can request
> more info in stmmac.txt, but calling me dishonest is a bit out of line.

If performance is a primary, if not the only, reason to make this
configuration setting then not mentioning it definitely falls into
the category of "sin of omission."

Please stop trying to weasel word your way out of this situation.

You're not interacting with the community properly, and your
unwillingness to do simple things people ask of you wrt. patch
submission and testing is upsetting a lot of people.
