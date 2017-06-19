From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 03/11] net: mvmdio: use GENMASK for masks
Date: Mon, 19 Jun 2017 10:49:26 -0400 (EDT)
Message-ID: <20170619.104926.732811694966999045.davem@davemloft.net>
References: <20170614154911.14510-1-antoine.tenart@free-electrons.com>
        <20170614154911.14510-4-antoine.tenart@free-electrons.com>
        <063D6719AE5E284EB5DD2968C1650D6DD0025C9A@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: antoine.tenart@free-electrons.com, jason@lakedaemon.net,
        andrew@lunn.ch, gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        mw@semihalf.com, linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58568 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751762AbdFSOt2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 10:49:28 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD0025C9A@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Laight <David.Laight@ACULAB.COM>
Date: Mon, 19 Jun 2017 11:57:51 +0000

> From: Antoine Tenart
>> Sent: 14 June 2017 16:49
>> Cosmetic patch to use the GENMASK helper for masks.
> ...
>> -	ret = val & 0xFFFF;
>> +	ret = val & GENMASK(15, 0);
> 
> My 2c: It isn't at all clear to me that changes like this in anyway
> improve the code readability.
> In some sense the '15' should be a named constant - but that just makes
> it even less obvious what is going on.

I agree, a hexidecimal mask of 0xffff is 100 times more readable and
understandable to me than "SOME_MACRO(x, y)".
