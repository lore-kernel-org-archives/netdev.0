From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [PATCH v2] r8169: Fix sleeping function called during get_stats64
Date: Thu, 10 Sep 2015 10:35:54 +0200
Message-ID: <20150910083554.GA19486@calimero.vinschen.de>
References: <1441833400-2677-1-git-send-email-vinschen@redhat.com>
 <20150909.203147.2009094422078807401.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="wac7ysb48OaltWcw"
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com,
	pomidorabelisima@gmail.com, konrad@kernel.org,
	linux-kernel@vger.kernel.org, nic_swsd@realtek.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150909.203147.2009094422078807401.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--wac7ysb48OaltWcw
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sep  9 20:31, David Miller wrote:
> From: Corinna Vinschen <vinschen@redhat.com>
> Date: Wed,  9 Sep 2015 23:16:40 +0200
>=20
> > Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=3D104031
> > Fixes: 6e85d5ad36a26debc23a9a865c029cbe242b2dc8
> >=20
> > Based on the discussion starting at
> > http://www.spinics.net/lists/netdev/msg342193.html
> >=20
> > Tested locally on RTL8168evl/8111evl with various concurrent processes
> > accessing /proc/net/dev while changing the link state as well as
> > removing/reloading the r8169 module.
> >=20
> > Signed-off-by: Corinna Vinschen <vinschen@redhat.com>
>=20
> Please address Francois's minor feedback, camelcase drives me nuts
> too FWIW :-)

Haha, with pleasure.  I don't like them much either.  I just used
them to align to the original code, which uses camel back for the
rx/tx descriptor ring buffers allocated the same way.

I'll send a v3 in a minute which fixes all of Francois points.


Thanks,
Corinna

--wac7ysb48OaltWcw
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJV8UDqAAoJEPU2Bp2uRE+gx2MQAIl9ruw1SdVsZTL88+e31X54
Wspj7fIKZBYA8oxYjvHGoEhm3CPUm9PjwXEhRF719IcKmqc+0Vl868k7g0UEhSLS
1d9MNk7vyEVuvW80U75BSDKXTn6J47yM2Zi1x++ABC9CnkwQHrTsTSot8KzRurql
ckYH3XAo62nC82sYdYYlZ2P6t2DY+qVAp5tujzSwbZTKXYPT9+h9sl8EaStSOReW
BA1o7OP6bnSy2s5JSGm05ajGPtSIh7dg1ViPKVR9kJqrmZ3HamT0EpMU12wwtW0+
DxAcnJDhesNkne0iffwnz42h5fTZTKOtmo4o4YtJXVAQmQZQkf45dpKpouB/lm+t
nymNkh9kagZkptmxvI1iSt88xrvHeUr6TBg0itMQGWsTsBMr402Ih7JW/hI7XIjf
5w/oYlOtCFO5VizOIiPmWw0fKM7mEABONF4bxHTTttwF24Zq/iOpE2/ao/641dJb
Y42tW0DSH/jvhyXXVQ5F3XO5KiuKnj1+I4mqMrjG3AE6JGAkIJxJBKQ9TuqNlb+/
uojK5zAnmUqCUP5By8X4RPXfL2ltOrfAIcGOPQAF3JcpgsfG3e+tqMJbIPt/qvqf
zVw+F/hDZiXfeRytXRSMjgOwcvChDhyFfR/xRfkU/sOAZ2cu5NRwbc5ykiQhAJlV
w9YAuIz9pnwAbu69QWaN
=SlXL
-----END PGP SIGNATURE-----

--wac7ysb48OaltWcw--
