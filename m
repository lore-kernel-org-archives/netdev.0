From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Wed, 03 Dec 2008 21:25:42 -0800 (PST)
Message-ID: <20081203.212542.139360072.davem@davemloft.net>
References: <Pine.LNX.4.64.0812031320340.31282@wrl-59.cs.helsinki.fi>
	<1228315025.4112.21.camel@nathan.suse.cz>
	<Pine.LNX.4.64.0812032025570.26311@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ptesarik@suse.cz, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49384
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751497AbYLDFZm convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Dec 2008 00:25:42 -0500
In-Reply-To: <Pine.LNX.4.64.0812032025570.26311@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Wed, 3 Dec 2008 20:31:09 +0200 (EET)

> On Wed, 3 Dec 2008, Petr Tesarik wrote:
>=20
> > Ilpo J=E4rvinen p=EDse v St 03. 12. 2008 v 13:22 +0200:
> > Yes, re-fragmenting the packet here is probably the best way to go.=
 But
> > repeating the same condition on multiple places is not so nice. Wha=
t
> > about this little improvement?
>=20
> Yeah, this too will work... Though not of too much significance since
> I've already most of unification of those two functions in a local
> queue awaiting testing, polish up and submit to net-next.
>=20
> When sending an updated version davem prefers to have full changelog =
in it=20
> btw, it saves some work for him.
>=20
> > (I didn't roll the revert of 33cf71cee1 into it, as it makes the ac=
tual
> > change less obvious. I think there are better ways of doing a rever=
t in
> > git.)
>=20
> Whatever, I've no strong opinion either way though it's just broken w=
ith=20
> and without the revert anyway, the full thing is needed to actually f=
ix=20
> it.

I've applied Ilpo's version of the fix patch, thanks everyone.
