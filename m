From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH v2 net-next] net: stmmac: add drop transmit status feature
Date: Wed, 12 Apr 2017 16:13:33 +0100
Message-ID: <13ddd2d8-c2a4-4983-a9af-8e34f605374c@synopsys.com>
References: <37cc8294-5514-ed02-9b41-86f8cc9c20ad@synopsys.com>
 <20170412135239.GD32596@lunn.ch>
 <efbda38a-2146-06b2-9151-19294c654d28@synopsys.com>
 <20170412.105101.58827766857310782.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <andrew@lunn.ch>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay4.synopsys.com ([198.182.47.9]:55161 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752650AbdDLPNs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 11:13:48 -0400
In-Reply-To: <20170412.105101.58827766857310782.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello,

Às 3:51 PM de 4/12/2017, David Miller escreveu:
> From: Joao Pinto <Joao.Pinto@synopsys.com>
> Date: Wed, 12 Apr 2017 14:55:03 +0100
> 
>> Understand your point, but for now our development and testing setup will be
>> based on the IP Prototyping Kit, consisting of a FPGA + PHY.
> 
> That's completely, and utterly, unacceptable.
> 
> I will be quite frank with you, that instances like this are causing
> people to contact me privately and telling me that your handling of
> becomming the stmmac driver maintainer is causing very real and
> serious concerns.

So, adding features to the driver are causing concerns to people? People don't
have to worry about maintenance, since goals are not to be a maintainer. My job
is just to help improve and add missing features to the driver and that's it.

> 
> You cannot develop performance based features and only test their
> impact on FPGA when almost all users are on real silicon.
> 
> And this requirement is absolutely non-negotiable.
> 
> You must test the impact on real silicon otherwise your performance
> numbers, which are required to be provided in the commit message
> for any "performance" feature or change, are completely useless.

Next time I won't mention anything about performance, honestly. "Drop TX Status"
is just an IP Core feature that can or not be used, it is up to the driver user.

> 
> I want your attitude on these matters to change quickly, as myself
> and many other interested parties are becomming extremely frustrated
> with how you are handling things.

Attitude? Are there complaints with my attitude? I try to help in everything I
can, I listen to feedback, I did the rework on the Multiple Buffers patch to try
to solve the negative impact in sunxi board. Sincerely I don't see a bad attitude.

Are you mentioning the e-mail about sxgbe?

> 
> Thank you.
> 

Thank you.
