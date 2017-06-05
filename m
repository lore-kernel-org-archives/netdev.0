From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 1/2] net: emac: fix reset timeout with AR8035 phy
Date: Mon, 05 Jun 2017 17:54:57 -0400 (EDT)
Message-ID: <20170605.175457.683161131295339666.davem@davemloft.net>
References: <20170605212617.GC9339@lunn.ch>
        <21110017.iteKCRmsvN@debian64>
        <20170605214857.GB12386@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chunkeey@googlemail.com, netdev@vger.kernel.org, ivan@de.ibm.com,
        chrisrblake93@gmail.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44604 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751189AbdFEVy7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 17:54:59 -0400
In-Reply-To: <20170605214857.GB12386@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Mon, 5 Jun 2017 23:48:57 +0200

> On Mon, Jun 05, 2017 at 11:44:46PM +0200, Christian Lamparter wrote:
>> On Monday, June 5, 2017 11:26:17 PM CEST Andrew Lunn wrote:
>> > > In order to stay compatible with existing configurations, the
>> > > driver will try the normal reset first and only falls back to
>> > > to the internal clock, after the first reset fails. If the
>> > > second reset fails as well, it will give up as before.
>> > 
>> > Hi Christian
>> > 
>> > This gets things probed correctly. But should you swap back to the PHY
>> > clock when the PHY declares the link up? Is there code already to do
>> > this?
>> > 
>> > 	Andrew
>> > 
>> Oh, sorry. I omitted this from the commit message. But the proposed 
>> emac_reset() code  switched to the internal clock only after the first attempt
>> has failed AND only for the duration of the reset.
>> 
>> If the reset succeeds or the reset times out, the clock is always switched 
>> back to the external clock.
> 
> Thanks for the clarification. Maybe add it to the commit message.

Indeed, please do.

 
