From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: stmmac: add drop transmit status
 feature
Date: Wed, 12 Apr 2017 11:28:25 -0400 (EDT)
Message-ID: <20170412.112825.1170167825508436176.davem@davemloft.net>
References: <efbda38a-2146-06b2-9151-19294c654d28@synopsys.com>
        <20170412.105101.58827766857310782.davem@davemloft.net>
        <13ddd2d8-c2a4-4983-a9af-8e34f605374c@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: andrew@lunn.ch, netdev@vger.kernel.org
To: Joao.Pinto@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46832 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752379AbdDLP20 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 11:28:26 -0400
In-Reply-To: <13ddd2d8-c2a4-4983-a9af-8e34f605374c@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joao Pinto <Joao.Pinto@synopsys.com>
Date: Wed, 12 Apr 2017 16:13:33 +0100

> Às 3:51 PM de 4/12/2017, David Miller escreveu:
>> You cannot develop performance based features and only test their
>> impact on FPGA when almost all users are on real silicon.
>> 
>> And this requirement is absolutely non-negotiable.
>> 
>> You must test the impact on real silicon otherwise your performance
>> numbers, which are required to be provided in the commit message
>> for any "performance" feature or change, are completely useless.
> 
> Next time I won't mention anything about performance, honestly. "Drop TX Status"
> is just an IP Core feature that can or not be used, it is up to the driver user.

Being dishonest about why a change might be desirable doesn't help things, in fact
now that you've stated this intent in the future, people know to be suspucious of
your changes.

I seriously don't think you realize the ramifications of what you just said right
there.

Everything here is about trust, and if you create a situation where you can't be
trusted then the process of doing upstream development will be extremely difficult
and time consuming for you.

Thanks.
