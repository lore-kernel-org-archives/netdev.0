From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 0/3]: Three TCP fixes
Date: Wed, 05 Dec 2007 02:30:30 -0800 (PST)
Message-ID: <20071205.023030.125862645.davem@davemloft.net>
References: <11967869303114-git-send-email-ilpo.jarvinen@helsinki.fi>
	<47559FA1.2090104@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44829
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751095AbXLEKac convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2007 05:30:32 -0500
In-Reply-To: <47559FA1.2090104@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: John Heffner <jheffner@psc.edu>
Date: Tue, 04 Dec 2007 13:42:41 -0500

> Ilpo J=E4rvinen wrote:
> > ...I'm still to figure out why tcp_cwnd_down uses snd_ssthresh/2
> > as lower bound even though the ssthresh was already halved,=20
> > so snd_ssthresh should suffice.
>=20
> I remember this coming up at least once before, so it's probably wort=
h a=20
> comment in the code.  Rate-halving attempts to actually reduce cwnd t=
o=20
> half the delivered window.  Here, cwnd/4 (ssthresh/2) is a lower boun=
d=20
> on how far rate-halving can reduce cwnd.  See the "Bounding Parameter=
s"=20
> section of <http://www.psc.edu/networking/papers/FACKnotes/current/>.

I assume we're talking about the tcp_cwnd_min() usage in
tcp_cwnd_down(), I don't see where it's dividing by two
there.

Anyways, someone please enlighten me and please also cook
up a patch to add the descriptive comment :-)

Thanks!
