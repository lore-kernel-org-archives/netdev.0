From: David Miller <davem@davemloft.net>
Subject: Re: net: fec: fix regression on i.MX28 introduced by rx_copybreak
 support
Date: Wed, 05 Nov 2014 15:52:07 -0500 (EST)
Message-ID: <20141105.155207.760255373450633226.davem@davemloft.net>
References: <20141104112912.2be8bf1a@ipc1.ka-ro>
	<20141104.112858.356827532569349127.davem@davemloft.net>
	<20141105062148.2a997b95@ipc1.ka-ro>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fabio.estevam@freescale.com, Frank.Li@freescale.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	rmk+kernel@arm.linux.org.uk, linux-arm-kernel@lists.infradead.org
To: LW@KARO-electronics.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141105062148.2a997b95@ipc1.ka-ro>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Lothar Wa=DFmann <LW@KARO-electronics.de>
Date: Wed, 5 Nov 2014 06:21:48 +0100

> David Miller wrote:
>> Because it goes "(n + (d - 1)) / d"
>>=20
>> Which for 'd' of 4 gives:
>>=20
>> 1 --> 4
>> 2 --> 4
>> 3 --> 4
>> 4 --> 4
>>
> '1', not '4'.
> The loop has to be done once for each (probably partial) WORD of inpu=
t
> data, not for each BYTE.

You're right, thanks for being so patient with me.

Please repost your patch, I'll integrate it.

Thanks.
