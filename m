From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: 2.6.25rc7 lockdep trace
Date: Fri, 04 Apr 2008 16:48:12 +0200
Message-ID: <1207320492.19189.33.camel@johannes.berg>
References: <1206752049.22530.105.camel@johannes.berg>
	 <20080328.180631.91055366.davem@davemloft.net>
	 <1206784948.22530.128.camel@johannes.berg>
	 <20080403.134813.201577998.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-SNb9fDTkIyoNKm3WTlYj"
Cc: davej@codemonkey.org.uk, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:57493 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756713AbYDDOsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2008 10:48:18 -0400
In-Reply-To: <20080403.134813.201577998.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-SNb9fDTkIyoNKm3WTlYj
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


On Thu, 2008-04-03 at 13:48 -0700, David Miller wrote:
> From: Johannes Berg <johannes@sipsolutions.net>
> Date: Sat, 29 Mar 2008 11:02:28 +0100
>=20
> > However, as I just tried to explain, cancel_work_sync() _is_ safe to ru=
n
> > while holding the RTNL because it doesn't need any runqueue lock.
>=20
> So in theory we should be able to safely transform
> flush_scheduled_work() calls in network driver close
> methods into cancel_work_sync()?

Yes, more precisely cancel_work_sync() for each work struct the driver
uses, unless the driver actually requires that the work runs before it
goes down.

johannes

--=-SNb9fDTkIyoNKm3WTlYj
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR/Y/q6Vg1VMiehFYAQKItg//ZvPnyoIqM4lwX/90sqlIekEWmhuc17BO
Dnfiru3XXOKhjhdbzmZt6NnQJJKPAIkHaPJp6aV9vetFee9gj7HxNbL9uUMGC4GK
r7lA/LJDh+oJE/baeUxMRAkWh2sdF1giVaA7wo8JIJfVtC/gvAcNtaXJeTWkL0K8
peFwfeBsvQqOLkaKQrinpfrVQscYrCgvnu5em2f78eDD5xFavQ3Y+iHWnM6b5yWi
XeTgRQubocM1vJ+W3MBVgfbqS9xFbaSO3CtJ7xsG8HGgAsvamMx9hdPTehxXdXGO
347PDpdCMcXW3RCnwBSiqjOTVLJx6fbWW75m+DC+MxkLjlnWfyDHxzKHbDpzELiy
tpWWKJhZvg1qF/KK5+0yamryhlsVoYHC6p90eaG7XYVhco1FVgdHRqrGs/PNx1F/
N7xtM5N4LS/v/2cCkLEmzTiqyzUwANiRf56ge7X3P3zrB1ZVxaLEcMKbiHrFkyKK
Jo5LZrrfrOBBsLfwHCMX7S5WxWMJMUnCHpPHEIPRVUfNpTnRlk7L2yS+h8BeR9QB
pjMvzjb6Igr1/L5eCLo97LVITXqxhuEtInJ9MSmUCV1hgAZxpYwQUoVstgqLP87m
umwoL+hyfI1W6kDv2vcif1D7QgedTrU49StQqtOhMK8kzjzAA2196q2eT6JRbhTW
3xrpohd66vA=
=TThB
-----END PGP SIGNATURE-----

--=-SNb9fDTkIyoNKm3WTlYj--

