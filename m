From: Carlos =?utf-8?Q?Mart=C3=ADn?= Nieto <carlos@cmartin.tk>
Subject: Re: tiacx module fail
Date: Tue, 12 Sep 2006 00:40:04 +0200
Message-ID: <20060911224004.GB3878@kiopa.cmartin.tk>
References: <4503F640.3040300@fastwebnet.it> <20060911122541.GA4537@kiopa.cmartin.tk> <450560F6.5030405@fastwebnet.it> <20060911200343.GA3878@kiopa.cmartin.tk> <4505CF96.4060602@fastwebnet.it>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="IiVenqGWf+H9Y6IX"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 144.red-82-159-197.user.auna.net ([82.159.197.144]:39888 "EHLO
	indy.cmartin.tk") by vger.kernel.org with ESMTP id S932277AbWIKWkI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Sep 2006 18:40:08 -0400
To: VinX <vincenx@fastwebnet.it>
Content-Disposition: inline
In-Reply-To: <4505CF96.4060602@fastwebnet.it>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--IiVenqGWf+H9Y6IX
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Sep 11, 2006 at 11:05:26PM +0200, VinX wrote:
> Carlos Mart=C3=ADnn Nieto wrote:
> >  Did you bring the interface up (ifconfig eth1 up)? It won't work
> > before that because parts of the card haven't been initialised.
> ok, now it seems to work!
>=20
> > IIRC, the tiacx module in wireless-2.6 uses softmac and we never
> > managed to get it working properly. There is a version with the
> > devicescape stack which seems to work, though it might take a bit of
> > hunting down.
> ah ok, but why doesn't work it with acx module?
> if i use a kernel <=3D 2.6.16, it works fine...
> uhm... in the lastest kernels there are some changes that they are
> indipendent on a generic wireless module, is it correct?

 One of the changes is that it now has acx_common.ko, acx_usb.ko and
acx_pci.ko instead of just acx.ko (before that, it was acx-usb.ko and
acx-pci.ko whith the common code in each one). This patch was applied
upstream after the conversion to softmac IIRC.

 I haven't followed the kernel much these last few months, so I'm not
sure when each event happened, but it would seem that it was after
=2E16 when the softmac code got in. (This being the wireless-2.6
kernel, not mainline, which AFAIK doesn't have acx at all).

 I'm still not sure why it didn't work with the softmac stack, but I
think it was a problem telling the stack what the card received. I
think there were plans to put the devicescape stack into the mainline
kernel, so ideally the version of acx that uses it is the one that
should get merged upstream. I'm not sure where to find this version,
but asking the author (search the acx archives for him) should fix that.

   cmn
--=20
Carlos Mart=C3=ADn Nieto    |   http://www.cmartin.tk
Hobbyist programmer    |
--IiVenqGWf+H9Y6IX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQFFBeXEEVXxXOiy6a4RAkurAKCQmp/5LfaSUxpDwveFJFB1M7/hfwCfW0Ab
YwAkCxegORFbbwDWBC9ExPk=
=+zIt
-----END PGP SIGNATURE-----

--IiVenqGWf+H9Y6IX--
