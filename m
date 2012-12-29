From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: Slow speed of tcp connections in a network namespace
Date: Sat, 29 Dec 2012 09:40:28 -0800
Message-ID: <1356802828.21409.4623.camel@edumazet-glaptop>
References: <20121229092417.GA4038@paralelels.com>
	 <1356789203.21409.3923.camel@edumazet-glaptop>
	 <20121229145030.GA7959@paralelels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, vvs@parallels.com,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
To: Andrew Vagin <avagin@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:64570 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752940Ab2L2Rkc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2012 12:40:32 -0500
Received: by mail-pa0-f51.google.com with SMTP id fb11so6566023pad.10
        for <netdev@vger.kernel.org>; Sat, 29 Dec 2012 09:40:32 -0800 (PST)
In-Reply-To: <20121229145030.GA7959@paralelels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-12-29 at 18:50 +0400, Andrew Vagin wrote:
> On Sat, Dec 29, 2012 at 05:53:23AM -0800, Eric Dumazet wrote:
> > > 3.8-rc1 is used for experiments.
> > >=20
> > > Do you have any ideas where is a problem?
> >=20
> > veth has absolutely no offload features
> >=20
> > It needs some care...
> >=20
> > At the very miminum, let TCP coalesce do its job by allowing SG
> >=20
> > CC Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl> for insights=
=2E
> >=20
> > Please try following patch :
>=20
> Hello Eric,
>=20
> Thanks for your feedback.
>=20
> With this patch the results is a bit better (~4MB/s), but it's much l=
ess
> than in the root netns.

Please post your new tcpdump then ;)

also post "netstat -s" from root and test ns after your wgets
