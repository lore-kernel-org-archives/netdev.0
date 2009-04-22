From: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
Subject: Re: [PATCH v2 fixed] e100: do not go D3 in shutdown unless system
	is powering off
Date: Wed, 22 Apr 2009 16:37:29 -0300
Message-ID: <20090422193728.GI4691@vespa.holoscopio.com>
References: <1240237621-11415-1-git-send-email-cascardo@holoscopio.com> <200904202114.01932.rjw@sisk.pl> <20090421215248.GF6147@vespa.holoscopio.com> <200904220017.19670.rjw@sisk.pl> <20090422043828.GB3979@vespa.holoscopio.com> <9929d2390904212246n4817b25r4db653cd7e6a24c1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="B8ONY/mu/bqBak9m"
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from liberdade.minaslivre.org ([72.232.18.203]:35190 "EHLO
	liberdade.minaslivre.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752339AbZDVThg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 15:37:36 -0400
Content-Disposition: inline
In-Reply-To: <9929d2390904212246n4817b25r4db653cd7e6a24c1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--B8ONY/mu/bqBak9m
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Apr 21, 2009 at 10:46:19PM -0700, Jeff Kirsher wrote:
> On Tue, Apr 21, 2009 at 9:38 PM, Thadeu Lima de Souza Cascardo
> <cascardo@holoscopio.com> wrote:
> > After experimenting with kexec with the last merges after 2.6.29, I've
> > had some problems when probing e100. It would not read the eeprom. After
> > some bisects, I realized this has been like that since forever (at least
> > 2.6.18). The problem is that shutdown is doing the same thing that
> > suspend does and puts the device in D3 state. I couldn't find a way to
> > get the device back to a sane state in the probe function. So, based on
> > some similar patches from Rafael J. Wysocki for e1000, e1000e and ixgbe,
> > I wrote this one for e100.
> >
> > Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
> > ---
>=20
> Thanks, I will add it to my queue of patches for e100.
>=20
> Also, just FYI, Auke is no longer a maintainer for
> e100/e1000/e1000e/igb/ixgb/ixgbe devices, so I have removed him from
> the thread.
>=20
> --=20
> Cheers,
> Jeff

Perhaps, Rafael should be mentioned in a Reviewed-by? As well as you if
you did review it? I guess a Tested-by and Reported-by me is overkill,
right? :-)

--B8ONY/mu/bqBak9m
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAknvcfgACgkQyTpryRcqtS3ANACfUvn/zTDz/Mk8MlleZZT1f948
zDMAnRimUtGoQLo9ueLJxJZAb/IXF/uG
=LUbo
-----END PGP SIGNATURE-----

--B8ONY/mu/bqBak9m--
