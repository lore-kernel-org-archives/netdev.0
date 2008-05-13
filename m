From: David Miller <davem@davemloft.net>
Subject: Re: Fix FRTO+NewReno problem
Date: Tue, 13 May 2008 02:49:15 -0700 (PDT)
Message-ID: <20080513.024915.161125347.davem@davemloft.net>
References: <Pine.LNX.4.64.0805122143080.14152@wrl-59.cs.helsinki.fi>
	<20080512.154838.163999274.davem@davemloft.net>
	<Pine.LNX.4.64.0805130958001.14510@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: damon@damtek.com, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60713
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750814AbYEMJtV convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 05:49:21 -0400
In-Reply-To: <Pine.LNX.4.64.0805130958001.14510@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 13 May 2008 12:42:03 +0300 (EEST)

> On Mon, 12 May 2008, David Miller wrote:
>=20
> > If I understand correctly, it is only non-SACK newreno case that ca=
n
> > get the unnecessary retransmissions, right?  If so, it's not a big
> > deal at all.
>=20
> No, also SACK could get at least one quite easily if TCP has a small=20
> window, to get two of them with SACK one needs to have a stranger cas=
e
> unless I missed something. If I just remove that forward transmission=
 LOST=20
> marking avoidance unconditionally, it fixes that SACKFRTO window of=20
> failure too which was a pending thing to fix :-).

Ok.

> Btw, the first two fixes (workaround was not included) also fixed bug=
zilla=20
> #10063, I just got a confirmation about that as well.
>=20
> I'll send the two patches still pending separately in a minute.

Thank you.
