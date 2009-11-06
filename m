From: md@Linux.IT (Marco d'Itri)
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Fri, 6 Nov 2009 23:35:24 +0100
Message-ID: <20091106223524.GA27121@bongo.bofh.it>
References: <20091016003245.GD29672@ldl.fc.hp.com> <EDA0A4495861324DA2618B4C45DCB3EE589579@blrx3m08.blr.amer.dell.com> <20091016152053.GA9862@ldl.fc.hp.com> <1255707193.2869.12.camel@achroite> <20091016214024.GA10091@ldl.fc.hp.com> <EDA0A4495861324DA2618B4C45DCB3EE5895AF@blrx3m08.blr.amer.dell.com> <4ADC906E.2050909@kadzban.is-a-geek.net> <EDA0A4495861324DA2618B4C45DCB3EE5896D2@blrx3m08.blr.amer.dell.com> <20091106084921.GA16700@bongo.bofh.it> <20091106220637.GB15533@mock.linuxdev.us.dell.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="9jxsPFA5p3P2qPhR"
Cc: Narendra_K@Dell.com, bryan@kadzban.is-a-geek.net, dannf@hp.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, Jordan_Hargrave@Dell.com,
	Charles_Rose@Dell.com, Sandeep_K_Shandilya@Dell.com
To: Matt Domsch <Matt_Domsch@Dell.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091106220637.GB15533@mock.linuxdev.us.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--9jxsPFA5p3P2qPhR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Nov 06, Matt Domsch <Matt_Domsch@Dell.com> wrote:

> > As a distribution developer I highly value solutions like this which do
> > not require patching every application which deals with interface names
> > and then teaching users about aliases which only work in some places and
> > are unknown to the kernel.
> Fair enough - but would you object if we changed the naming scheme
> from eth%d to something else?
I suppose that this would depend on what else. :-)
Since you want radical changes I recommend that you design the new
persistent naming infrastructure in a way that will allow root to choose
to use the classic naming scheme, or many users will scream a lot and at
least some distributions will do it anyway.
I also expect that providing choice at the beginning of development may
lead to more acceptance later if and when the new scheme will have
proved itself to be superior (at least in some situations).
You have tought about this for a long time and if so far you have not
found a solution which is widely considered superior then I doubt that
one will appear soon. Providing your favourite naming scheme as an
optional add on will immediately benefit those who like it and greatly
reduce opposition from those who do not.

--=20
ciao,
Marco

--9jxsPFA5p3P2qPhR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkr0pKYACgkQFGfw2OHuP7H5BwCbBUMc7gwZfrtXtzLZL6lElyW9
vRUAn3Is6fnuP8KtjJ+oGqKqaUMluuDY
=QHfm
-----END PGP SIGNATURE-----

--9jxsPFA5p3P2qPhR--
