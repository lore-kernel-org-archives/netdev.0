From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH v5] net: ethernet: add driver for Aurora VLSI NB8800 Ethernet controller
Date: Tue, 10 Nov 2015 21:21:00 +0000
Message-ID: <yw1xvb99pn43.fsf@unicorn.mansr.com>
References: <yw1xr3jxraqs.fsf@unicorn.mansr.com>
	<20151110.150403.1195107307226924000.davem@davemloft.net>
	<yw1xziylpoe8.fsf@unicorn.mansr.com>
	<20151110.160615.1511568572619688788.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, slash.tmp@free.fr
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151110.160615.1511568572619688788.davem@davemloft.net> (David
	Miller's message of "Tue, 10 Nov 2015 16:06:15 -0500 (EST)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: M=E5ns Rullg=E5rd <mans@mansr.com>
> Date: Tue, 10 Nov 2015 20:53:19 +0000
>
>> David Miller <davem@davemloft.net> writes:
>>=20
>>> From: M=E5ns Rullg=E5rd <mans@mansr.com>
>>> Date: Tue, 10 Nov 2015 18:05:15 +0000
>>>
>>>> Because I haven't been following the netdev list closely for the l=
ast
>>>> five years, and no documentation I read mentioned this function.  =
I can
>>>> certainly change it.
>>>
>>> It is always advisable to mimick what other drivers do and use them=
 as
>>> a reference, rather than depend upon documentation which by definit=
ion
>>> is always going to be out of sync with the source tree.
>>=20
>> Sure.  The trick is to pick the right driver(s) to use as reference.
>> Quite a few of them don't use that function.
>
> If you really are stumped on this matter, start at least with the
> ixgbe driver.  In fact pretty much every Intel ethernet driver is
> a reasonable reference.  Others to check out are bnx2x and mlx5.

Even ixgbe uses napi_complete() while netdevice.h says one should
"consider using napi_complete_done() instead."  Did the author consider
it and decide not to, or has the driver simply not been updated?

As for the napi_gro_receive() function, calling that instead of
netif_receive_skb() is easy enough, or are there other things I should
be doing in addition?

--=20
M=E5ns Rullg=E5rd
mans@mansr.com
