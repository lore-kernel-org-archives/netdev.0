From: David Miller <davem@davemloft.net>
Subject: Re: dmfe/tulip device id overlap
Date: Mon, 30 Nov 2009 14:29:25 -0800 (PST)
Message-ID: <20091130.142925.23220838.davem@davemloft.net>
References: <da824cf30911300914p2d08b87cr4625e9bc30ec7e5b@mail.gmail.com>
	<20091130.122642.113956563.davem@davemloft.net>
	<20091130222219.GA8073@jenkins.domain_not_set.invalid>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grundler@google.com, tobias@ringis.se, kyle@mcmartin.ca,
	netdev@vger.kernel.org, grundler@parisc-linux.org
To: brandon@ifup.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54184
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750828AbZK3W3T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 17:29:19 -0500
In-Reply-To: <20091130222219.GA8073@jenkins.domain_not_set.invalid>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brandon Philips <brandon@ifup.org>
Date: Mon, 30 Nov 2009 14:22:20 -0800

> On 12:26 Mon 30 Nov 2009, David Miller wrote:
>> From: Grant Grundler <grundler@google.com>
>> Date: Mon, 30 Nov 2009 09:14:01 -0800
>> > Has anyone posted "lspci -v" output for the "Netra X1 and Sunfire
>> > V100" motherboards?
>> > 
>> > I'm asking because I'm hoping it's possible to disambiguate the add-on
>> > cards from
>> > LAN-on-Motherboard cases by looking at subsystem vendor and device IDs as well.
>> 
>>             subsystem-id:  0000434e
>>             subsystem-vendor-id:  00004554
>>
>> Hmmm, what vendor is '0x4554'? :-)
> 
> Whoever it is it is the same as the expansion card on non-sparc
> boards: SubVendor: pci 0x4554 [1]
> 
> Hrm, dead end I guess.

We still have the OF properties.  So we can simply look for
merely the existence of a 'compatible' OF property on the
device and from that we'll know that it's a Sparc onboard
instance of this thing.
