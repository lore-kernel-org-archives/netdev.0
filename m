From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH] Stop scaring users with "treason uncloaked!"
Date: Thu, 18 Dec 2008 17:50:34 -0600
Message-ID: <1229644234.3726.577.camel@calx>
References: <1229638581.3726.546.camel@calx>
	 <Pine.LNX.4.64.0812190028560.12061@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:41015 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750894AbYLRXu4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Dec 2008 18:50:56 -0500
In-Reply-To: <Pine.LNX.4.64.0812190028560.12061@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-12-19 at 00:33 +0200, Ilpo J=C3=A4rvinen wrote:
> On Thu, 18 Dec 2008, Matt Mackall wrote:
>=20
> > These debug messages are uninformative and extremely alarming. Rath=
er
> > than reporting a peer as a treacherous attacker, report it more
> > correctly as simply broken.=20
>=20
> Last time (well, ignoring some report on ancient vendor kernel) I've =
seen=20
> this to trigger it wasn't the fault of the peer but ours (we sent pas=
t the=20
> advertized window and window ended up being shrunk to zero). I agree =
that=20
> the message as-is is not very good but your change is not very good=20
> either.

Here this is the bulk of messages on my server (which is otherwise
fairly quiet).

It really doesn't matter whether the message is technically accurate -
it's mostly there for the benefit of kernel hackers. The average end
user is not going to have the slightest clue what is going on nor shoul=
d
they even care. An advanced network admin might be able to figure thing=
s
out by poking at packet traces, but again: not much reason to care. For
most admins, the vast majority of these treasonous peers won't be under
their administrative control.=20

If you want, we can instead say "Peer %d unexpectedly shrunk window..."=
=2E
So long as the scary bit is gone, I don't care.

--=20
Mathematics is the supreme nostalgia of our time.

