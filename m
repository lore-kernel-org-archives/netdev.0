From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] bonding: Don't allow mode change via sysfs with slaves
 present
Date: Tue, 15 Nov 2011 19:33:17 +0000
Message-ID: <1321385597.2744.11.camel@bwh-desktop>
References: <1321375482-8637-1-git-send-email-vfalico@redhat.com>
	 <20111115170018.GB25132@gospo.rdu.redhat.com>  <4EC2BC6D.9000304@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	<netdev@vger.kernel.org>, Jay Vosburgh <fubar@us.ibm.com>
To: Nicolas de =?ISO-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:27024 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756356Ab1KOTdW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 14:33:22 -0500
In-Reply-To: <4EC2BC6D.9000304@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-11-15 at 20:24 +0100, Nicolas de Peslo=C3=BCan wrote:
> Le 15/11/2011 18:00, Andy Gospodarek a =C3=A9crit :
> > On Tue, Nov 15, 2011 at 05:44:42PM +0100, Veaceslav Falico wrote:
> >> When changing mode via bonding's sysfs, the slaves are not initial=
ized
> >> correctly. Forbid to change modes with slaves present to ensure th=
at every
> >> slave is initialized correctly via bond_enslave().
> >>
> >> Signed-off-by: Veaceslav Falico<vfalico@redhat.com>
> >
> > Looks good.  This behavior forces someone who wants to change to mo=
de to
> > go through steps that are almost as destructive as when module opti=
ons
> > are used to configure the mode.  I do not see a problem with this.
>=20
> Except the fact that is enforce one more constraint on the exact orde=
r one should write into sysfs=20
> to setup a bonding interface. We already have many such constraints a=
nd probably don't need more.

=46rom the administrator perspective, perhaps.  From the developer
perspective, the current flexibility of bonding makes it very difficult
to test and maintain.

> Currently, it is possible to enslave slaves before selecting the mode=
=2E The ifenslave-2.6 package=20
> from Debian currently enslave slaves before setting the mode and woul=
d break with this change.
>=20
> NAK.

It sounds like this feature has to be kept and fixed, then.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
