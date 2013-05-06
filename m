From: Jean Delvare <jdelvare@suse.de>
Subject: Re: [PATCH] S390: Fix libphy link failure
Date: Mon, 06 May 2013 17:17:17 +0200
Message-ID: <1367853437.4569.126.camel@chaos.site>
References: <1367852019.4569.123.camel@chaos.site>
	 <20130506.110011.1813294677998011362.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, heiko.carstens@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:60232 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753714Ab3EFPSX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 May 2013 11:18:23 -0400
In-Reply-To: <20130506.110011.1813294677998011362.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Le Monday 06 May 2013 =C3=A0 11:00 -0400, David Miller a =C3=A9crit :
> From: Jean Delvare <jdelvare@suse.de>
> Date: Mon, 06 May 2013 16:53:39 +0200
>=20
> > On S390 basic IRQ functions are provided by the PCI subsystem, so
> > code which calls these cannot be built if PCI support was not
> > selected.
> >=20
> > Signed-off-by: Jean Delvare <jdelvare@suse.de>
> > Cc: "David S. Miller" <davem@davemloft.net>
> > Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> > ---
> > I know this isn't nice, but in the current state of S390 support
> > this is all I can offer.
>=20
> I really am tired of all of these special S390 dependencies.
>=20
> You can't say this is a new problem, because we've been hitting this
> issue repeatedly for more than a decade.  And I don't want to hear an=
y
> excuses, we've all already invested enough time into this to prove
> that catering to S390's weird build limitations is a never ending
> burdon for non-s390 people.
>=20
> Really, our interfaces are abstract enough that every driver ought to
> be buildable on every architecture.
>=20
> It's time to put the burdon on your side, if you don't support some
> IRQ interface or whatever, provide a stub that returns an error
> rather than being that "special architecture" that everything else
> has to specially cater for with ugly Kconfig dependencies.

=46air enough, I tend to agree with you. S390 isn't my thing in the fir=
st
place. I was only trying to help fix a build regression (make
allmodconfig fails on 32-bit S390.)

--=20
Jean Delvare
Suse L3
