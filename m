From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 11/39] wimax: RF-kill framework integration
Date: Thu, 27 Nov 2008 10:56:20 +0100
Message-ID: <1227779780.3809.45.camel@johannes.berg>
References: <cover.1227691434.git.inaky@linux.intel.com>
	 <3db0d6b9524acff7af098c46dfc9dc8d4f17acba.1227691434.git.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-uWAok5/1pz/cktMi3k2Q"
Cc: netdev <netdev@vger.kernel.org>
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:58163 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752394AbYK0J47 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 04:56:59 -0500
In-Reply-To: <3db0d6b9524acff7af098c46dfc9dc8d4f17acba.1227691434.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-uWAok5/1pz/cktMi3k2Q
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2008-11-26 at 15:07 -0800, Inaky Perez-Gonzalez wrote:

> +struct genl_ops wimax_gnl_rfkill =3D {
> +	.cmd =3D WIMAX_GNL_OP_RFKILL,
> +	.flags =3D 0,

permissions thing again

Also, doesn't rfkill already have a userspace interface in sysfs? Why
add another one?

johannes

--=-uWAok5/1pz/cktMi3k2Q
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJLm7BAAoJEKVg1VMiehFY+wsP/j3OC0tpRKZAzoOkpSzMR5yQ
z1L/KXEeTWyIkNZKFQHR3+GmoEEhfDx0XmAemM6u91zbDIQ8F6JyIA4bV+FDUfcr
tkGaMmWEGV9aW95MSmdHuZZKtJ3MLgxLFGwnA1HPHFhGCx+mZbZ5tqW3sAofjLLq
YUEvAURURszOsyzKBL3yF0DEyXSow5rtcKiIwk8yRvGAgIgbtIoNfnQ7YVBaEWwE
u2iYLgccefhP66UHL3G4fXd18wTuq3HtIue4IFxv7sSMGKCX6MFhxFQYxVWXqfd1
Znt+h3IEtpO1f58tx3iZ9TOlA0h7wQCveQ/TXu3QuXf7evwWdJjcJtGrPv3cP2f5
gzEXsWL3ogHpaAc8/Rukp6I6nCFkLTSlgOWXrJVahaR+XChRT2yj+Gp4QsdrLPy0
6VvsCZxBz4jd4yBFyMIhh0ZOhK0asYMymDIISjEnlDXrEVArYZc80T0QyCcC+Y2J
dPu+NCfDhLoSn8Qc/oescKgT4/y2pC/XhQlmNivsHL5PdJng6eT0+E7XezoGo9m6
lb7SLI88yaBTLCMPPPxSac/S/RPM3eeUIFFg9d0fwqVEuZXji68m5ApLrRKUlJx8
t1F0kt35aQQYztbYoT8p476le4yp5qdL1cJV+eYko4pywBgpVT8vPV/4gNqNupCE
P7ZHDhitSGJHdDrsS6Vh
=g1lU
-----END PGP SIGNATURE-----

--=-uWAok5/1pz/cktMi3k2Q--

