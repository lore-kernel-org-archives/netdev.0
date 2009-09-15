From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2nd try] tcp: fix ssthresh u16 leftover
Date: Tue, 15 Sep 2009 01:30:47 -0700 (PDT)
Message-ID: <20090915.013047.33116195.davem@davemloft.net>
References: <alpine.DEB.2.00.0909141705500.7424@wel-95.cs.helsinki.fi>
	<20090914.170555.154302240.davem@davemloft.net>
	<alpine.DEB.2.00.0909151111250.7424@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33582
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751614AbZIOIab convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2009 04:30:31 -0400
In-Reply-To: <alpine.DEB.2.00.0909151111250.7424@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 15 Sep 2009 11:19:11 +0300 (EEST)

> [PATCH 2nd try] tcp: fix ssthresh u16 leftover
>=20
> It was once upon time so that snd_sthresh was a 16-bit quantity.
> ...That has not been true for long period of time. I run across
> some ancient compares which still seem to trust such legacy.
> Put all that magic into a single place, I hopefully found all
> of them.
>=20
> Compile tested, though linking of allyesconfig is ridiculous
> nowadays it seems.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Much better, applied, thanks!
