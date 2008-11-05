From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: tbench wrt. loopback TSO
Date: Wed, 5 Nov 2008 16:04:05 +0300
Message-ID: <20081105130405.GA26435@ioremap.net>
References: <20081105114900.GA18691@ioremap.net> <20081105.035454.87914782.davem@davemloft.net> <Pine.LNX.4.64.0811051355550.23792@wrl-59.cs.helsinki.fi> <20081105.040943.03609283.davem@davemloft.net> <Pine.LNX.4.64.0811051414250.23792@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, efault@gmx.de, mingo@elte.hu,
	a.p.zijlstra@chello.nl, Herbert Xu <herbert@gondor.apana.org.au>
To: Ilpo =?utf-8?B?SsOkcnZpbmVu?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from broadrack.ru ([195.178.208.66]:46830 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750793AbYKENEM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2008 08:04:12 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0811051414250.23792@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 05, 2008 at 02:25:57PM +0200, Ilpo J=C3=A4rvinen (ilpo.jarv=
inen@helsinki.fi) wrote:
> The problem is that we'd need to _resegment with the next skb_ since =
the=20
> mss boundary and skb boundary would basically constantly be running=20
> out-of-sync. That won't get done currently by anything.

Btw, what's that wrong if there will be sub-mss frame per tso frame?

--=20
	Evgeniy Polyakov
