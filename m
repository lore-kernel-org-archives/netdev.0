From: Jann Horn <jann@thejh.net>
Subject: Re: [PATCH] netfilter: don't permit unprivileged writes to global
 state via sysctls
Date: Sat, 22 Oct 2016 23:23:42 +0200
Message-ID: <20161022212342.GD3334@pc.thejh.net>
References: <1474669264-3283-1-git-send-email-jann@thejh.net>
 <20161020182224.GA10999@salvia>
 <20161020.143747.1033652491220298518.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="u65IjBhB3TIa72Vp"
Cc: pablo@netfilter.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
        netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from thejh.net ([37.221.195.125]:45941 "EHLO thejh.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753168AbcJVVXq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 22 Oct 2016 17:23:46 -0400
Content-Disposition: inline
In-Reply-To: <20161020.143747.1033652491220298518.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--u65IjBhB3TIa72Vp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Oct 20, 2016 at 02:37:47PM -0400, David Miller wrote:
> From: Pablo Neira Ayuso <pablo@netfilter.org>
> Date: Thu, 20 Oct 2016 20:22:24 +0200
>=20
> > On Sat, Sep 24, 2016 at 12:21:04AM +0200, Jann Horn wrote:
> >> This prevents the modification of nf_conntrack_max in unprivileged net=
work
> >> namespaces. For unprivileged network namespaces, ip_conntrack_max is k=
ept
> >> as a readonly sysctl in order to minimize potential compatibility issu=
es.
> >>=20
> >> This patch should apply cleanly to the net tree.
> >=20
> > For the record: This patch looks good to me, but this legacy
> > ip_conntrack sysctl code is now gone.
> >=20
> > I don't know what is the procedure to get this to -stable branches now
> > that this cannot be pushed upstream.
>=20
> In the commit message for the -stable submission simply say "Not
> applicable" in the upstream commit reference.  Like:
>=20
> 	[ Upstream commit: Not applicable ]
>=20
> or something like that.

Who should do that? Me, after getting a maintainer ack? Or the maintainer?

--u65IjBhB3TIa72Vp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJYC9jeAAoJED4KNFJOeCOoO5oP/0tMy+rqViZRPYgKDNhVStXg
slHeHpxhGcVhUUmpHPOyjdoAeKxsWLIeJ7mYS35quWuQeRwdnv6060Z3cUUEeDvT
0m27p7Y1+qYV9HmSvaEeWGpVu3WgT4D/+HqOvHeCUCcA+yNRNXLS7kzIvrJweCxy
Bvrv9sI6LCRVqCYM0tjhr3flEIwZuGhWLWrc4qE+MefUvgkSjLJqVlAaiTIrVcV4
UMjCHmy4GdcWiPsv2ZO3PwuRBnsjTdjYuSdOukPqivZCHa1v0gNmBYOiY3rZKrSG
r0Fbuk9Z8X+Bq51nl1CNy1LnLshOOYM3GJDbRTr2X2zu7WAhUCpHMPhwxGxQ9LdE
2b0V+I9qKH8A+wvdSu0oDswxb9AdEKw4zeeIgNu1JaTK4NuXIyPWM/TYrZ10p3LM
QfDaG67VslsPs/AdmfXnayxf5+XR9V2M6PJ3uQl6QlwjbzJ4KI/+FQZZOQ1iWw32
31C9ssSPvlELmQ/YEFGMOCjybFTwYolkStQVCQ0ADQeOnBGU4Os6E3XVBcz6GqJr
mrhdMgcurUGmceMye085KO5Oj/MvQVm/j9FFUmox22QNA0J5lGQgFQ28s45lxVGK
sco9n8YX1aQslKP8G6phoNU3BGve9lF7u5sApvY/T+YoH8YmFAKRQK/26ohy+25p
hGImiqWL4p9DTh2A1rpa
=qA2f
-----END PGP SIGNATURE-----

--u65IjBhB3TIa72Vp--
