From: David Miller <davem@davemloft.net>
Subject: Re: Disabling msix interrupts
Date: Tue, 07 Feb 2017 11:26:45 -0500 (EST)
Message-ID: <20170207.112645.492478528794181275.davem@davemloft.net>
References: <063D6719AE5E284EB5DD2968C1650D6DB027CB6A@AcuExch.aculab.com>
        <20170206.141449.371774071782410941.davem@davemloft.net>
        <063D6719AE5E284EB5DD2968C1650D6DB027DA37@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.duyck@gmail.com, netdev@vger.kernel.org,
        linux-pci@vger.kernel.org
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50920 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751540AbdBGQ0t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 11:26:49 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB027DA37@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Laight <David.Laight@ACULAB.COM>
Date: Tue, 7 Feb 2017 09:55:47 +0000

> From: David Miller
>> Sent: 06 February 2017 19:15
>> From: David Laight <David.Laight@ACULAB.COM>
>> Date: Mon, 6 Feb 2017 17:23:54 +0000
>> 
>> > Although the 'store buffer' on the sparc cpus I used to use would
>> > let reads overtake writes. So you did have to read back the address
>> > of the last write - not sure about modern sparc cpus.
>> 
>> Never would any sparc cpu do so when any of the operations involved
>> were to "side effect" locations, as PCI config space is.
> 
> I guess they used non-zero ASI, and that forced the flush??
> Normal uncached memory reads would overtake writes.
> (These were SuperSparc (Viking)).

On sun4m it was controlled by bits in the physical address.
