From: John Heffner <jheffner@psc.edu>
Subject: Re: TSO trimming question
Date: Thu, 20 Dec 2007 11:02:21 -0500
Message-ID: <476A920D.6020401@psc.edu>
References: <Pine.LNX.4.64.0712192336130.27945@kivilampi-30.cs.helsinki.fi>	<20071219.235450.170670042.davem@davemloft.net>	<Pine.LNX.4.64.0712201253400.31652@kivilampi-30.cs.helsinki.fi> <20071220.035621.147230372.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.66.106]:49418 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765449AbXLTQCl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 11:02:41 -0500
In-Reply-To: <20071220.035621.147230372.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Thu, 20 Dec 2007 13:40:51 +0200 (EET)
>=20
>> [PATCH] [TCP]: Fix TSO deferring
>>
>> I'd say that most of what tcp_tso_should_defer had in between
>> there was dead code because of this.
>>
>> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
>=20
> Yikes!!!!!
>=20
> John, we've been living a lie for more than a year. :-/
>=20
> On the bright side this explains a lot of small TSO frames I've been
> seeing in traces over the past year but never got a chance to
> investigate.

Ouch.  This fix may improve some benchmarks.

Re-checking this function was on my list of things to do because I had=20
also noticed some TSO frames that seemed a bit small.  This clearly=20
explains it.

   -John
