From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH] net: stmmac: add drop transmit status feature
Date: Tue, 11 Apr 2017 16:10:05 +0100
Message-ID: <f5249fd2-0d68-3cdc-effe-fc0a677ed263@synopsys.com>
References: <738665b880f7c661c4108d34a9d8fc43ef2f9fa4.1491921785.git.jpinto@synopsys.com>
 <20170411150458.GK27307@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, Joao Pinto <Joao.Pinto@synopsys.com>,
        Niklas Cassel <niklas.cassel@axis.com>,
        Thierry Reding <thierry.reding@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay.synopsys.com ([198.182.47.9]:55241 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752437AbdDKPKM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 11:10:12 -0400
In-Reply-To: <20170411150458.GK27307@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Às 4:04 PM de 4/11/2017, Andrew Lunn escreveu:
> On Tue, Apr 11, 2017 at 03:44:10PM +0100, Joao Pinto wrote:
>> When the Drop Transmit Status bit is set, the Tx packet status
>> received from the MAC is dropped in the MTL. When this bit is reset,
>> the Tx packet status received from the MAC is forwarded to the
>> application. This feature will cause a performance improvement.
> 
> Hi Joao
> 
> Is there a reason not to turn this on by default?

The only reason is not to cause problems for other people setup by introducing a
new variable. In my setup is set by default.

@Niklas and Thierry: Could you please test this feature in order to see if it
boosts your perfomance? If it works fine in your setup we can follow Andrew idea
to turn it on by default.

> 
>    Andrew
> 

Thanks.
