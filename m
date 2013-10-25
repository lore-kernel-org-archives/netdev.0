From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [RFC PATCHv2 3/4] of: provide a binding for fixed link PHYs
Date: Fri, 25 Oct 2013 05:40:57 +0100
Message-ID: <1811694.J4B6oUpKxP@lenovo>
References: <1378480701-12908-1-git-send-email-thomas.petazzoni@free-electrons.com> <20130918042923.5D845C42CF7@trevor.secretlab.ca> <20130918181112.56c10dde@skate>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Grant Likely <grant.likely@secretlab.ca>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, Lior Amsalem <alior@marvell.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Christian Gmeiner <christian.gmeiner@gmail.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:43588 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750878Ab3JYElD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 00:41:03 -0400
In-Reply-To: <20130918181112.56c10dde@skate>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 18 septembre 2013, 18:11:12 Thomas Petazzoni a =E9crit :
> Dear Grant Likely,
>=20
> On Tue, 17 Sep 2013 23:29:23 -0500, Grant Likely wrote:
> > I understand what you're trying to do here, but it causes a trouble=
some
> > leakage of implementation detail into the binding, making the whole
> > thing look very odd. This binding tries to make a fixed link look
> > exactly like a real PHY even to the point of including a phandle to=
 the
> > phy. But having a phandle to a node which is *always* a direct chil=
d of
> > the MAC node is redundant and a rather looney. Yes, doing it that w=
ay
> > makes it easy for of_phy_find_device() to be transparent for fixed =
link,
> > but that should *not* drive bindings, especially when that makes th=
e
> > binding really rather weird.
> >=20
> > Second, this new binding doesn't provide anything over and above th=
e
> > existing fixed-link binding. It may not be pretty, but it is
> > estabilshed.
>=20
> Have you followed the past discussions about this patch set? Basicall=
y
> the *only* feedback I received on RFCv1 is that the fixed-link proper=
ty
> sucks, and everybody (including the known Device Tree binding
> maintainer Mark Rutland) suggested to not use the fixed-link mechanis=
m.
> See http://article.gmane.org/gmane.linux.network/276932, where Mark
> said:
>=20
> ""
> I'm not sure grouping these values together is the best way of handli=
ng
> this. It's rather opaque, and inflexible for future extension.
> ""
>=20
> So, please DT maintainers, tell me what you want. I honestly don't ca=
re
> whether fixed-link or a separate node is chosen. However, I do care
> about being dragged around between two solutions just because the
> former DT maintainer and the new DT maintainers do not agree.

Since I would like to move forward so I can one day use that binding in=
 a=20
real-life product, I am going to go for Mark's side which happens to be=
 how I=20
want the binding to look like.

Do we all agree that the new binding is just way better than the old on=
e? In=20
light of the recent unstable DT ABI discussion, we can still continue p=
arsing=20
the old one for the sake of compatibility.
--=20
=46lorian
