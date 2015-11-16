From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH v6] net: ethernet: add driver for Aurora VLSI NB8800 Ethernet controller
Date: Mon, 16 Nov 2015 20:59:18 +0000
Message-ID: <yw1xsi45irtl.fsf@unicorn.mansr.com>
References: <1447698216-7635-1-git-send-email-mans@mansr.com>
	<20151116.155327.1432148371996261050.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151116.155327.1432148371996261050.davem@davemloft.net> (David
	Miller's message of "Mon, 16 Nov 2015 15:53:27 -0500 (EST)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: Mans Rullgard <mans@mansr.com>
> Date: Mon, 16 Nov 2015 18:23:35 +0000
>
>> +static int nb8800_alloc_rx(struct net_device *dev, int i, bool napi=
)
>
> "i" is passed in as a signed int here, but:
>
>> +static void nb8800_receive(struct net_device *dev, unsigned i, unsi=
gned len)
>  ...
>> +		err =3D nb8800_alloc_rx(dev, i, true);
>
> It comes from an 'unsigned' value.
>
> Please pick one type and use it consistently.

Darn, missed one.

> Also, always fully spell out "unsigned int" rather than use "unsigned=
"
> as a shorthand.

OK

Anything else?

--=20
M=E5ns Rullg=E5rd
mans@mansr.com
