From: Olaf Hering <olaf@aepfle.de>
Subject: Re: [PATCH v14 net-next 1/1] hv_sock: introduce Hyper-V Sockets
Date: Fri, 1 Jul 2016 08:42:40 +0200
Message-ID: <20160701064240.GA19086@aepfle.de>
References: <CY1PR03MB21865E21E637F03877784979BF240@CY1PR03MB2186.namprd03.prod.outlook.com>
 <20160630161212.GA7456@aepfle.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3189355261347578229=="
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 Haiyang Zhang <haiyangz@microsoft.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "joe@perches.com" <joe@perches.com>,
 Rolf Neugebauer <rolf.neugebauer@docker.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 Vitaly Kuznetsov <vkuznets@redhat.com>,
 "davem@davemloft.net" <davem@davemloft.net>
To: Dexuan Cui <decui@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20160630161212.GA7456@aepfle.de>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org


--===============3189355261347578229==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="zhXaljGHf11kAtnf"
Content-Disposition: inline


--zhXaljGHf11kAtnf
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jun 30, Olaf Hering wrote:

> On Thu, Jun 30, Dexuan Cui wrote:
>=20
> > -#define AF_MAX		43	/* For now.. */
> > +#define AF_MAX		44	/* For now.. */
>=20
> Should this patch also change the places where AF_MAX is used,
> like all the arrays in net/core/sock.c?

Also, there are appearently two competing changes for AF_MAX, one is
yours and the other one is AF_SMC. I'm not subscribed to netdev, so its
not clear which one gets applied first.

Olaf.

--zhXaljGHf11kAtnf
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iEYEARECAAYFAld2ENoACgkQXUKg+qaYNn6ArACgpph8IVgAV222xs3tYf1v+fqc
ckIAn1eDUjwvukXAlBbGw6HI1TEK+CH0
=wGN+
-----END PGP SIGNATURE-----

--zhXaljGHf11kAtnf--

--===============3189355261347578229==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
devel mailing list
devel@linuxdriverproject.org
http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel

--===============3189355261347578229==--
