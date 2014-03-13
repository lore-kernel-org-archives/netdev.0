From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next v2 00/10][pull request] Intel Wired LAN Driver Updates
Date: Thu, 13 Mar 2014 15:48:38 -0700
Message-ID: <1394750918.2167.26.camel@jtkirshe-mobl>
References: <1394677890-11043-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20140313.150403.1216425576381362401.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Mr/p8bM00PT9f7OUqBAT"
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:59991 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755484AbaCMWsm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Mar 2014 18:48:42 -0400
In-Reply-To: <20140313.150403.1216425576381362401.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Mr/p8bM00PT9f7OUqBAT
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-03-13 at 15:04 -0400, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Wed, 12 Mar 2014 19:31:20 -0700
>=20
> > This series contains updates to igb, e1000e, ixgbe and ixgbevf.
> >=20
> > Tom Herbert provides changes to e1000e, igb and ixgbe to call skb_set_h=
ash()
> > to set the hash and its type in an skbuff.
> >=20
> > Carolyn provides a fix for igb where using ethtool for EEE settings, wh=
ich
> > was not working correctly.
> >=20
> > Jacob provides some trivial cleanups and fixes for ixgbe which mainly
> > dealt with the file headers.
> >=20
> > Julia Lawall provides a one fix for ixgbevf where the driver did not ne=
ed
> > to adjust the power state on suspend, so the call to pci_set_power_stat=
e()
> > in the resume function was a no-op.
> >=20
> > v2:
> > - dropped patches 4-6 from original series which implemented debugfs fo=
r
> >   igb from Carolyn based on feed back from David Miller and Or Gerlitz
>=20
> Pulled, thanks a lot Jeff.
>=20
> BTW, from patch #3:
>=20
> +	/*Re-establish EEE setting */
>=20
> There really should be a space after "/*", please fix this up in a future
> pull request.
>=20
> Thanks.

Putting together a patch (and series now).  Thanks Dave!

--=-Mr/p8bM00PT9f7OUqBAT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJTIjXGAAoJEOVv75VaS+3OowIP/RK1x7/sQWuZh/whRh2uzcNV
qD1sl/clFnXRukr9uImE3AJzWMCStIX0srmRUcTwLRpj40PHsuMs293DPf6GOFv6
F1MGikwVop2hDL4SA1M9v57sFj46GHccBdYWzv/F11YLGpj4oyVH7ZwAAa1ZbcFd
PSFkzkXVkv/gXh3kC+sZW9R1/YoxMORi/UxyRX81uJpRVNWn0QE6Z+JF76IkIcco
DNNOcBFDVSLqQsTTlIxI6pEPazhBMxSmb+KroLACjX+1C8tzhbmJotqLxDDt/M7w
alSVxGLZIR4wRoRR4lq5ZPxjL3XM3PvWWDcvsKSDtVYISzf8OunbMYaaiMfEN0J7
Vg+evxK1+UxNk0MMwiKQ8QSxmdH2gPeUTWFg1fF03BD+MHse0mm6q1A4+uyb8Qd2
E74Wx0qXtQVYxEYMVotyT/nFmhmKIZMXdEj0kqxIZh1x77TsFUbS3KAqjuxVqpLF
zXN0l8SXi2V/PsEdMwa5x9coF/UMTQ4RsBNL++TQMPlcsBqf7Ym3/9+2blRmHVIN
kDpzs/n2J5aVGNJSVPHtFxZefsNbCMqyNsYUVgI5mUFQJairsw8BEpxrGmWz0zcK
xqKLK1KNRWrueLyMjwR9XCAacZvMm4ah9mcxEWUgtesR6+BcXOMjmxhnryNidSXa
8HkRMZjARh88m1tfs0R0
=mKvi
-----END PGP SIGNATURE-----

--=-Mr/p8bM00PT9f7OUqBAT--
