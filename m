From: David Miller <davem@davemloft.net>
Subject: Re: [Uclinux-dist-devel] [PATCH 1/5] netdev: bfin_mac: Blackfin
 EMAC interrupt may not be shared
Date: Fri, 29 May 2009 15:09:28 -0700 (PDT)
Message-ID: <20090529.150928.239765896.davem@davemloft.net>
References: <8bd0f97a0905290422x502d6006yb05ebe231b05e9bc@mail.gmail.com>
	<20090529.042817.176293351.davem@davemloft.net>
	<8bd0f97a0905290445x3b0829f3h657fec534f290c7f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael.Hennerich@analog.com, netdev@vger.kernel.org,
	uclinux-dist-devel@blackfin.uclinux.org
To: vapier.adi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54633
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750811AbZE2WJ3 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 May 2009 18:09:29 -0400
In-Reply-To: <8bd0f97a0905290445x3b0829f3h657fec534f290c7f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Mike Frysinger <vapier.adi@gmail.com>
Date: Fri, 29 May 2009 07:45:05 -0400

> On Fri, May 29, 2009 at 07:28, David Miller wrote:
>> From: Mike Frysinger <vapier.adi@gmail.com>
>>> why implement extra over head in an interrupt handler to support an
>>> operating mode the hardware can never support.
>>
>> What overhead? =A0It should be pretty easy to see if the device
>> is really indicating an interrupt or not :-)
>=20
> which would involve reading system mmrs which are clocked at the
> system frequency and thus make the core stall

And the core doesn't stall reading in these cache lines that the chip
has just DMA'd to?

I think you're throwing the baby out with the bath water :-)
