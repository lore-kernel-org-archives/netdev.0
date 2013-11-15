From: Sebastian Reichel <sre-8fiUuRrzOP0dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 1/4] wl1251: split wl251 platform data to a separate
 structure
Date: Fri, 15 Nov 2013 14:55:56 +0000
Message-ID: <20131115145555.GA23351@earth.universe>
References: <1382890469-25286-1-git-send-email-sre@debian.org>
 <1382890469-25286-2-git-send-email-sre@debian.org>
 <20131114185132.GQ10317@atomide.com>
 <20131114230330.GB6383@earth.universe>
 <20131114232217.GV10317@atomide.com>
 <20131115143254.GA7079@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="BXVAT5kNtrzKuDFl"
Cc: Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>, Luciano Coelho <luca-XPOmlcxoEMv1KXRcyAk9cg@public.gmane.org>,
	Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>,
	Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>,
	Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	Rob Landley <rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org>,
	Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>,
	Sachin Kamat <sachin.kamat-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Bill Pemberton <wfp5p-4Ng6DfrEGID2fBVCVOL8/A@public.gmane.org>,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Luciano Coelho <coelho-l0cyMroinI0@public.gmane.org>
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20131115143254.GA7079-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--BXVAT5kNtrzKuDFl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Nov 15, 2013 at 09:32:55AM -0500, John W. Linville wrote:
> On Thu, Nov 14, 2013 at 03:22:18PM -0800, Tony Lindgren wrote:
> > * Sebastian Reichel <sre-8fiUuRrzOP0dnm+yROfE0A@public.gmane.org> [131114 15:04]:
> > > On Thu, Nov 14, 2013 at 10:51:33AM -0800, Tony Lindgren wrote:
> > > > [...]
> > > >
> > > > If this is not going into v3.13, these will cause conflicts
> > > > with the mach-omap2/board-*.c files for v3.14.
> > > >=20
> > > > So it might be best to do a minimal header patch first that
> > > > can be merged in by both linux-omap and wireless trees.
> > >=20
> > > I guess this patch is pretty minimal. It also seems to be acked by
> > > the involved Maintainers, so maybe just merge Patch 1 without the
> > > other patches?
> > >=20
> > > This does not solve the problem with the struct modification from
> > > the second patch, but I guess it's the more intrusive patch.
> >=20
> > Once at least the first two patches are ready, how about I queue
> > them after -rc1 and set up an immutable branch that can be merged
> > in by linux-omap tree and the wireless tree?
>=20
> That sounds reasonable to me.

So what changes do you request for those patches? I will try to
update them as soon as possible.

-- Sebastian

--BXVAT5kNtrzKuDFl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAEBCAAGBQJShjX7AAoJENju1/PIO/qaOgcQAIFxSRKg6g82sFajCuGZfI7s
t34ArIr0cWzxtFnPw0TE4lGaCPKmUpxdCj3568m6ejI7ZjZvZTD0rO02SS6v0jWM
7tAgYLXjoBmP4haZ1OfjJitZuQmk/YsBckAjegd3dIGeKO0xroNuIe3yfTIuVFR8
pFc6cOhFESwT2oPxjh6rAxkHBhhubXIDFnscJWc85JdhN37s8kEfIJPRpDkYWNzE
6Wun2h3/QzYPPQeVfCLUEL956Vif3Qp/KlKfPRhhd9/5LVUjKzCRij/B2jnB1Ufq
aZJrRgXq8k9EvIMCUamIgtRwvi3RvhNrE3gET6F0dy9qnwYb1Iqg0CLX1tW5Rrc5
D1iAFNeYSXXyl3TtnEaoJjMjTHxIGQJhrh27eTD/ChC59kssmNCwpMEDUq13Z4NT
Ve5tzgbOt3om4RVLdDux443wVbdPwNqjdnDQkLX52yQmMOec33deFTxzNtMEVakN
+vSdwLhHVgdd27llrqpePQGu7ELRVPRwGAKw7JBZzFkE8kbJSzNFvevpMZHe1dDX
xacBI4c4oiOPgjd7AuEepXeEIaTJ5F+Evzw7ZZPOs4A9vWpPaPm35c0dzQoswAjH
MHYdO5tuUU6Tm95Fy6jj+SOTjgSlHhq0XS0HbrdgC1pC97ROoLjet3j8fV/aK/mc
pTx51yqDqRfkjjWgkydn
=QcUk
-----END PGP SIGNATURE-----

--BXVAT5kNtrzKuDFl--
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
