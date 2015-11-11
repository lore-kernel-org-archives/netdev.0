From: Mason <slash.tmp@free.fr>
Subject: Re: [PATCH v5] net: ethernet: add driver for Aurora VLSI NB8800
 Ethernet controller
Date: Wed, 11 Nov 2015 14:41:24 +0100
Message-ID: <56434584.2090802@free.fr>
References: <yw1xr3jxraqs.fsf@unicorn.mansr.com>
 <20151110.150403.1195107307226924000.davem@davemloft.net>
 <yw1xziylpoe8.fsf@unicorn.mansr.com>
 <20151110.160615.1511568572619688788.davem@davemloft.net>
 <yw1xvb99pn43.fsf@unicorn.mansr.com>
 <1447192280.17135.83.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mans Rullgard <mans@mansr.com>, David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447192280.17135.83.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/11/2015 22:51, Eric Dumazet wrote:

> On Tue, 2015-11-10 at 21:21 +0000, M=E5ns Rullg=E5rd wrote:
>=20
>> Even ixgbe uses napi_complete() while netdevice.h says one should
>> "consider using napi_complete_done() instead."  Did the author consi=
der
>> it and decide not to, or has the driver simply not been updated?
>=20
> napi_complete_done() is quite new, very few drivers use it.

I was hoping to back-port this driver for my platform. Are the recent
features used in the driver available in 4.1? What about 3.14?

Regards.
