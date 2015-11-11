From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] net: ethernet: add driver for Aurora VLSI NB8800
 Ethernet controller
Date: Wed, 11 Nov 2015 14:13:11 -0500 (EST)
Message-ID: <20151111.141311.1893172622045238748.davem@davemloft.net>
References: <yw1xk2poo0la.fsf@unicorn.mansr.com>
	<20151111.140252.2214540370641368590.davem@davemloft.net>
	<yw1xfv0cnyjk.fsf@unicorn.mansr.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: romieu@fr.zoreil.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, slash.tmp@free.fr
To: mans@mansr.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <yw1xfv0cnyjk.fsf@unicorn.mansr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: M=E5ns Rullg=E5rd <mans@mansr.com>
Date: Wed, 11 Nov 2015 19:09:19 +0000

> David Miller <davem@davemloft.net> writes:
>=20
>> From: M=E5ns Rullg=E5rd <mans@mansr.com>
>> Date: Wed, 11 Nov 2015 18:25:05 +0000
>>
>>> If the TX DMA channel is idle when start_xmit is called, it can be
>>> started immediately.  Checking the DMA status and starting it if
>>> idle has to be done atomically somehow.
>>
>> ->ndo_start_xmit() is guaranteed to be invoked atomically, protected
>> by the TX queue spinlock.
>=20
> Yes, but the DMA needs to be restarted from some other context if it =
was
> busy when start_xmit checked.

Then you can probably use the TXQ lock in the interrupt handler just fo=
r
that.
