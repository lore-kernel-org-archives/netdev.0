From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC 0/3] Add support for led triggers on phy link state change
Date: Fri, 7 Oct 2016 16:13:10 +0200
Message-ID: <20161007141310.GD19976@amd>
References: <1473890149-2066-1-git-send-email-zach.brown@ni.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5339857830793109259=="
Cc: devel@driverdev.osuosl.org, florian.c.schilhabel@googlemail.com,
 f.fainelli@gmail.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 Larry.Finger@lwfinger.net, mlindner@marvell.com
To: Zach Brown <zach.brown@ni.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1473890149-2066-1-git-send-email-zach.brown@ni.com>
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


--===============5339857830793109259==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="d9ADC0YsG2v16Js0"
Content-Disposition: inline


--d9ADC0YsG2v16Js0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> Some drivers that include phy.h defined LED_OFF which conflicts with
> definition in leds.h. phy led support uses leds.h so the two namespaces a=
re no
> longer isolated.
> The first two patches fix the two net drivers that declared enum constant=
s that
> conflict with enum constants in linux/leds.h.

Perhaps led patches should be cced to led mainainters?

LED SUBSYSTEM
M:      Richard Purdie <rpurdie@rpsys.net>
M:      Jacek Anaszewski <j.anaszewski@samsung.com>
L:      linux-leds@vger.kernel.org

									Pavel


--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--d9ADC0YsG2v16Js0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlf3rXYACgkQMOfwapXb+vLmwQCfXmxzpPeaw7MxX0NlJBwEpD7R
gI4An0v7OFnWb2JIUVKD0dYo1b29Ml+D
=OIm+
-----END PGP SIGNATURE-----

--d9ADC0YsG2v16Js0--

--===============5339857830793109259==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
devel mailing list
devel@linuxdriverproject.org
http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel

--===============5339857830793109259==--
