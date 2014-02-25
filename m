From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] net: kdoc struct net_device flags and priv_flags
Date: Tue, 25 Feb 2014 02:11:05 +0000
Message-ID: <1393294265.6823.154.camel@deadeye.wl.decadent.org.uk>
References: <1393287245-4549-1-git-send-email-mcgrof@do-not-panic.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-KIdEAk1LqGPJ6HCaYEf8"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Luis R. Rodriguez" <mcgrof@suse.com>
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393287245-4549-1-git-send-email-mcgrof@do-not-panic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-KIdEAk1LqGPJ6HCaYEf8
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-02-24 at 16:14 -0800, Luis R. Rodriguez wrote:
> From: "Luis R. Rodriguez" <mcgrof@suse.com>
>=20
> We have documentation for these flags but they're scattered
> all over the place. #defines don't allow documentation to be
> written easily so to help to start bringing some documentation
> together use the enums kdoc practice but keep the defines to
> allow userspace to be able to #ifdef them.
>=20
> I've verified the same values are assigned before and after
> with a simple userspace test program [0] and checksumming the
> output.
>=20
> [0] http://drvbp1.linux-foundation.org/~mcgrof/kdoc/netdev_flags/
>=20
> mcgrof@gnat ~/tmp $ ./check-flags | sha1sum
> 0ec5b6b1840aa3bb9ce464e61c564820871c92c3  -
>=20
> Cc: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>
> ---
>  include/uapi/linux/if.h | 201 +++++++++++++++++++++++++++++++++++-------=
------
>  1 file changed, 149 insertions(+), 52 deletions(-)
>=20
> diff --git a/include/uapi/linux/if.h b/include/uapi/linux/if.h
> index d758163..1555623 100644
> --- a/include/uapi/linux/if.h
> +++ b/include/uapi/linux/if.h
[...]
> +/**
> + * enum net_device_priv_flags - &struct net_device priv_flags
> + *
> + * These are the &struct net_device, they are only set internally
> + * by drivers and used in the kernel but are invisible to userspace.
[...]

Indeed, I wonder why they are in the UAPI header.  As userland doesn't
have a legitimate use for them, maybe you could move them back to
include/linux/if.h instead of bothering with adding macros?

Ben.

--=20
Ben Hutchings
Everything should be made as simple as possible, but not simpler.
                                                           - Albert Einstei=
n

--=-KIdEAk1LqGPJ6HCaYEf8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUwv7uee/yOyVhhEJAQqL4RAAjeZK8JAnM7+VxCuNBx28qaIlEFSLHJ6e
sZUVJ7Zvh2mL1WRQwmWLyKN4nlp5keD/R02daDxAH1qVVtccE+b2wRusR6Q5RtlH
t72VKkrgrcx63PXdmOMcNvjxHV1s87HKiTgRE8O4C5sLPlAeyzuDw2OHJeUsAK7b
q0CixfZBa7QqJxqCfrdhkH9Hj+ymlaNqhs/n+C8Kvj/RIuzZp5pvZqgNOJKuWjA+
osq9K/nhfRLzCadPXgMnxvadPVfOpShDAD34q8UOMWKCUo8Zys6Xn0uJ/Y8V2xgC
7p5TKfx0mUm38YPH0mOmeXq6+h19itOBGbXr74ynHs7bjyjywvPiaURfU1bXrV/q
wXGo1jprvsby4gbY3Q5hp7dkwzZLwuQkpLaADa02jVD6aR04i0jmpxOU54N23Pk0
mNuHhreIqyV+6+rqfwuEH8U6aR29iKWDxDdiC9V4rqInh++qmHIiMBwlnwGTLTqC
ntr1Op77itDcixY0KPWGcPzd6ZzVlCFZOEG4vOOYLXEtRJzQbcdkLoWCdy7zvmBd
PZuMFwanPKpglfTZTh6iO49SRO7Fy9v+dBaOThRTg2EJx9nAeA1X9pLJEStU4Y9d
yWZ63AepZLcjDeQWKymf3Ltq7HYyGNO6E89dWP2oE1bSEHZz3FW2qnDNy6wRxJNO
WEkGg0dUsJQ=
=P2zm
-----END PGP SIGNATURE-----

--=-KIdEAk1LqGPJ6HCaYEf8--
