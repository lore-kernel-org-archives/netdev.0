From: Pavel Machek <pavel@ucw.cz>
Subject: stmmac: lockups (was Re: Synopsys Ethernet QoS)
Date: Wed, 14 Dec 2016 20:01:25 +0100
Message-ID: <20161214190125.GA28424@amd>
References: <CAHp75VcKURaTQX9=SY8+46GGATuwO1oXAi8eMS+uwk58sjKx5Q@mail.gmail.com>
 <3aee5a67-5e19-34e6-1719-ff13c7b914ea@gmail.com>
 <CAHp75VfT9B3O5jU0eHoKtgYc48K2ZjCQ-g9ZQ9nX1Hew6tz-zw@mail.gmail.com>
 <556353b7-c847-7549-626d-3c324063647e@gmail.com>
 <f5357ea2-a295-ab08-046e-f8b8f6ca4344@synopsys.com>
 <1d445ec1-deb8-6e36-39c4-6813c446095f@axis.com>
 <73bf8cb4-5685-2db6-529c-1de99b1fd358@st.com>
 <99424968-ad8f-fec6-ebcf-ab7b19ee5486@axis.com>
 <20161214125735.GA19542@amd>
 <79642215-95ce-7f04-3db7-121c585e2f2a@synopsys.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="2fHTh5uZTiUOsy+g"
Cc: Niklas Cassel <niklas.cassel@axis.com>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andy Shevchenko <andy.shevchenko@gmail.com>,
        David Miller <davem@davemloft.net>, larper@axis.com,
        rabinv@axis.com, netdev <netdev@vger.kernel.org>,
        CARLOS.PALMINHA@synopsys.com, Jie.Deng1@synopsys.com,
        Stephen Warren <swarren@nvidia.com>
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:51587 "EHLO
        atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753624AbcLNTB2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 14:01:28 -0500
Content-Disposition: inline
In-Reply-To: <79642215-95ce-7f04-3db7-121c585e2f2a@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--2fHTh5uZTiUOsy+g
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> I know that this is completely of topic, but I am facing a dificulty with
> stmmac. I have interrupts, mac well configured rx packets being received
> successfully, but TX is not working, resulting in Tx errors =3D Total TX =
packets.
> I have made a lot of debug and my conclusions is that by some reason when=
 using
> stmmac after starting tx dma, the hw state machine enters a deadend state
> resulting in those errors. Anyone faced this trouble?

Well.... what I'm debugging are lockups after many packets transmitted
(followed by netdev watchdog; stmmac_tx_err() does not work for me, it
kills the device even when run from working state; ifconfig down/up
helps). 4.4 locks up in minutes to hours, 4.9 seems to work better
(but I believe I seen a lockup there, too; once).

So... probably different problem?

Best regards,
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--2fHTh5uZTiUOsy+g
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhRlwUACgkQMOfwapXb+vJpdwCfQl+1eEvsQ6Ey3JL/cAbe/J2Z
IC4AoJ5Cem0MwBF7IzBVoHWgShr3qhq0
=TS4f
-----END PGP SIGNATURE-----

--2fHTh5uZTiUOsy+g--
