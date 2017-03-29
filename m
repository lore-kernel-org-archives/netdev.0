From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH net] ftgmac100: Mostly rewrite the driver
Date: Wed, 29 Mar 2017 16:03:07 +1100
Message-ID: <1490763787.3177.168.camel@kernel.crashing.org>
References: <1490762446.3177.164.camel@kernel.crashing.org>
         <20170328.215744.794906222630964588.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:50189 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752534AbdC2FD0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 29 Mar 2017 01:03:26 -0400
In-Reply-To: <20170328.215744.794906222630964588.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-03-28 at 21:57 -0700, David Miller wrote:
> This is unreviewable.
> 
> You must break this up into small, reviewable pieces.
> 
> If you didn't save the steps of your work in that way, that isn't
> our problem.

That's not realistic, it would probably not improve the readability
much. I basically ended up rewriting the driver almost completely
Dave. It's not even a matter of saving my work steps, each of them
involved pulling appart an entire side of the old driver and re-doing
it. 

That's why I said it's better reviewed as a new driver. We have no
other user of it in the tree anyway.

Do you prefer that I submit it as a new driver for that IP block
instead and take out the old one later ?

Cheers,
Ben.
