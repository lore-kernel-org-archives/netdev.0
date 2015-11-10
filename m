From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] net: ethernet: add driver for Aurora VLSI NB8800
 Ethernet controller
Date: Tue, 10 Nov 2015 16:06:15 -0500 (EST)
Message-ID: <20151110.160615.1511568572619688788.davem@davemloft.net>
References: <yw1xr3jxraqs.fsf@unicorn.mansr.com>
	<20151110.150403.1195107307226924000.davem@davemloft.net>
	<yw1xziylpoe8.fsf@unicorn.mansr.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, slash.tmp@free.fr
To: mans@mansr.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <yw1xziylpoe8.fsf@unicorn.mansr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: M=E5ns Rullg=E5rd <mans@mansr.com>
Date: Tue, 10 Nov 2015 20:53:19 +0000

> David Miller <davem@davemloft.net> writes:
>=20
>> From: M=E5ns Rullg=E5rd <mans@mansr.com>
>> Date: Tue, 10 Nov 2015 18:05:15 +0000
>>
>>> Because I haven't been following the netdev list closely for the la=
st
>>> five years, and no documentation I read mentioned this function.  I=
 can
>>> certainly change it.
>>
>> It is always advisable to mimick what other drivers do and use them =
as
>> a reference, rather than depend upon documentation which by definiti=
on
>> is always going to be out of sync with the source tree.
>=20
> Sure.  The trick is to pick the right driver(s) to use as reference.
> Quite a few of them don't use that function.

If you really are stumped on this matter, start at least with the
ixgbe driver.  In fact pretty much every Intel ethernet driver is
a reasonable reference.  Others to check out are bnx2x and mlx5.
