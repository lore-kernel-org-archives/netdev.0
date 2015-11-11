From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5] net: ethernet: add driver for Aurora VLSI NB8800
 Ethernet controller
Date: Wed, 11 Nov 2015 06:10:20 -0800
Message-ID: <1447251020.17135.105.camel@edumazet-glaptop2.roam.corp.google.com>
References: <yw1xr3jxraqs.fsf@unicorn.mansr.com>
	 <20151110.150403.1195107307226924000.davem@davemloft.net>
	 <yw1xziylpoe8.fsf@unicorn.mansr.com>
	 <20151110.160615.1511568572619688788.davem@davemloft.net>
	 <yw1xvb99pn43.fsf@unicorn.mansr.com>
	 <1447192280.17135.83.camel@edumazet-glaptop2.roam.corp.google.com>
	 <56434584.2090802@free.fr> <yw1xwptood3n.fsf@unicorn.mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mason <slash.tmp@free.fr>, David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33116 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752046AbbKKOKW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2015 09:10:22 -0500
In-Reply-To: <yw1xwptood3n.fsf@unicorn.mansr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-11-11 at 13:54 +0000, M=C3=A5ns Rullg=C3=A5rd wrote:
> Mason <slash.tmp@free.fr> writes:
>=20
> > On 10/11/2015 22:51, Eric Dumazet wrote:
> >
> >> On Tue, 2015-11-10 at 21:21 +0000, M=C3=A5ns Rullg=C3=A5rd wrote:
> >>=20
> >>> Even ixgbe uses napi_complete() while netdevice.h says one should
> >>> "consider using napi_complete_done() instead."  Did the author co=
nsider
> >>> it and decide not to, or has the driver simply not been updated?
> >>=20
> >> napi_complete_done() is quite new, very few drivers use it.
> >
> > I was hoping to back-port this driver for my platform. Are the rece=
nt
> > features used in the driver available in 4.1? What about 3.14?
>=20
> xmit_more was added in 3.18, napi_complete_done() in 3.19.

xmit_more is a hint, you can simply consider skb->xmit_more being
replaced by 0 on old kernels if you want to backport.
