From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround
Date: Fri, 22 Aug 2008 14:37:09 -0700 (PDT)
Message-ID: <20080822.143709.65615512.davem@davemloft.net>
References: <20080819213417.45133573@tux>
	<Pine.LNX.4.64.0808201358490.4551@wrl-59.cs.helsinki.fi>
	<20080822183224.2d52f16c@tux>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, netdev@vger.kernel.org, kaber@trash.net,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: fragabr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51722
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757792AbYHVVhL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Aug 2008 17:37:11 -0400
In-Reply-To: <20080822183224.2d52f16c@tux>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: D=E2niel Fraga <fragabr@gmail.com>
Date: Fri, 22 Aug 2008 18:32:24 -0300

> On Wed, 20 Aug 2008 15:37:13 +0300 (EEST)
> "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:
>=20
> > Based on irc discussion with davem, there is a htb bug which can ca=
use=20
> > corruption of the retransmitted TCP packets (and then a discard due=
 to=20
> > checksum mismatch). That would also explain the strange headers I n=
oticed=20
> > earlier. There's a patch below (should apply to 2.6.26), please put=
 it at=20
> > least on the host(s) which use htb (I don't know if both server and=
 the=20
> > client do use wondershaper script or just the client). An different=
=20
> > failure symptoms (one could be somehow frto related as FRTO is used=
 while=20
> > retransmitting) are also quite well explainable.
> >=20
> > But FRTO is mostly not a suspect based on the tcpdump you provided =
(no=20
> > FRTO workaround would help in that).
>=20
> 	Ilpo, I have good news. I decided to disable completely HTB and
> the problem seems to have gone. And frto is enabled, of course. So th=
e
> problem was with HTB, not frto as I thought.
>=20
> 	The HTB patches you provided are going to be included in the
> next 2.6.27 kernel, right?

Yes, but it's important that you verify that the patch makes the
problem go away when HTB is enabled.  Please make this test if you
can.
