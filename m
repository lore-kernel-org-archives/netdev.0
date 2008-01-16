From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: Re: Netperf TCP_RR(loopback) 10% regression in
	2.6.24-rc6,	comparing with 2.6.22
Date: Wed, 16 Jan 2008 08:34:04 +0800
Message-ID: <1200443644.3151.33.camel@ymzhang>
References: <1199871330.3298.132.camel@ymzhang>
	 <1200043854.3265.24.camel@ymzhang>
	 <Pine.LNX.4.64.0801141036400.31652@kivilampi-30.cs.helsinki.fi>
	 <20080114105307.GA22866@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:44914 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750963AbYAPAfc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jan 2008 19:35:32 -0500
In-Reply-To: <20080114105307.GA22866@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-01-14 at 21:53 +1100, Herbert Xu wrote:
> On Mon, Jan 14, 2008 at 08:44:40AM +0000, Ilpo J=E4rvinen wrote:
> >
> > > > I tried to use bisect to locate the bad patch between 2.6.22 an=
d 2.6.23-rc1,
> > > > but the bisected kernel wasn't stable and went crazy.
> >=20
> > TCP work between that is very much non-existing.
>=20
> Make sure you haven't switched between SLAB/SLUB while testing this.
I can make sure. In addition, I tried both SLAB and SLUB and make sure =
the=20
regression is still there if CONFIG_SLAB=3Dy.

Thanks,
-yanmin

