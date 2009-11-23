From: Joe Perches <joe@perches.com>
Subject: Re: [net-next-2.6 PATCH] net/ipv4: Move && and || to end of
 previous line
Date: Mon, 23 Nov 2009 14:14:06 -0800
Message-ID: <1259014446.16503.116.camel@Joe-Laptop.home>
References: <4B06AC2C.3070102@gmail.com>
	 <20091120.092651.254794724.davem@davemloft.net> <4B08D967.80003@gmail.com>
	 <20091122.163112.80105623.davem@davemloft.net>
	 <1259000895.16503.77.camel@Joe-Laptop.home>
	 <alpine.DEB.2.00.0911240004530.19211@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	william.allen.simpson@gmail.com, Netdev <netdev@vger.kernel.org>
To: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1100 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757110AbZKWWOC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2009 17:14:02 -0500
In-Reply-To: <alpine.DEB.2.00.0911240004530.19211@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-11-24 at 00:08 +0200, Ilpo J=C3=A4rvinen wrote:
> Certainly better in general already but there is still some work to b=
e=20
> done here as now you have an && only line. I guess it mostly has to d=
o=20
> with comments but #if... blahblahs could be another type of failure (=
in=20
> automation like this).

The current form is

	if (foo=20
#ifdef BAR
	    && bar
#endif
	   )

Another option could be:

#ifdef BAR
	if (foo && bar)
#else
	if (foo)
#endif

In any case, it won't be pretty.

