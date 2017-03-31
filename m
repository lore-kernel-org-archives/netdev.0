From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH net] ftgmac100: Mostly rewrite the driver
Date: Sat, 01 Apr 2017 08:14:27 +1100
Message-ID: <1490994867.3177.241.camel@kernel.crashing.org>
References: <e019331d-7050-ca6d-7f27-73878e290f7a@gmail.com>
         <1490821714.3177.189.camel@kernel.crashing.org>
         <1490834778.3177.197.camel@kernel.crashing.org>
         <20170329.201517.300684629549047939.davem@davemloft.net>
         <1490954367.3177.236.camel@kernel.crashing.org>
         <20170331135207.GG22609@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, f.fainelli@gmail.com,
        netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:46373 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753430AbdCaVOz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 31 Mar 2017 17:14:55 -0400
In-Reply-To: <20170331135207.GG22609@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-03-31 at 15:52 +0200, Andrew Lunn wrote:
> > We're running some more testing tonight, if it's all solid I'll shoot
> > it out tomorrow or sunday. Dave, it's ok to just spam the list with a
> > 55 patches series like that ?
> 
> Hi Ben
> 
> Is there a good reason to spam the list with 55 patches? The patches
> should be incremental, so getting them reviewed and applied in batches
> of 10 should not be a problem.

They are incremental, but some of them are trivial and in the end
it's the end result that matters but yes I could probably split some
misc stuff, rx path, tx path, and more misc.

I found an issue with link down vs. pending tx packets last night
so I need to fix that and test. I'll send things when that's done.

Cheers,
Ben.
