From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5] net: ethernet: add driver for Aurora VLSI NB8800
 Ethernet controller
Date: Wed, 11 Nov 2015 06:06:12 -0800
Message-ID: <1447250772.17135.101.camel@edumazet-glaptop2.roam.corp.google.com>
References: <yw1xr3jxraqs.fsf@unicorn.mansr.com>
	 <20151110.150403.1195107307226924000.davem@davemloft.net>
	 <yw1xziylpoe8.fsf@unicorn.mansr.com>
	 <20151110.160615.1511568572619688788.davem@davemloft.net>
	 <yw1xvb99pn43.fsf@unicorn.mansr.com>
	 <1447192280.17135.83.camel@edumazet-glaptop2.roam.corp.google.com>
	 <56434584.2090802@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mans Rullgard <mans@mansr.com>, David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Mason <slash.tmp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33012 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750961AbbKKOGP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2015 09:06:15 -0500
In-Reply-To: <56434584.2090802@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-11-11 at 14:41 +0100, Mason wrote:
> On 10/11/2015 22:51, Eric Dumazet wrote:
>=20
> > On Tue, 2015-11-10 at 21:21 +0000, M=C3=A5ns Rullg=C3=A5rd wrote:
> >=20
> >> Even ixgbe uses napi_complete() while netdevice.h says one should
> >> "consider using napi_complete_done() instead."  Did the author con=
sider
> >> it and decide not to, or has the driver simply not been updated?
> >=20
> > napi_complete_done() is quite new, very few drivers use it.
>=20
> I was hoping to back-port this driver for my platform. Are the recent
> features used in the driver available in 4.1? What about 3.14?

Sure, this is all available=20

napi_complete_done() can be backported on old kernels as a
napi_complete()=20
