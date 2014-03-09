From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 00/15][pull request] Intel Wired LAN Driver Updates
Date: Sat, 08 Mar 2014 17:12:57 -0800
Message-ID: <1394327577.2582.15.camel@jtkirshe-mobl>
References: <1394270741-29926-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20140308.185008.2040072445038361801.davem@davemloft.net>
	 <20140308.191007.432079065584935989.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Cr+TOlFRv8hzev4Up2DJ"
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:28234 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751610AbaCIBM7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Mar 2014 20:12:59 -0500
In-Reply-To: <20140308.191007.432079065584935989.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Cr+TOlFRv8hzev4Up2DJ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-03-08 at 19:10 -0500, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Sat, 08 Mar 2014 18:50:08 -0500 (EST)
>=20
> > From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date: Sat,  8 Mar 2014 01:25:26 -0800
> >=20
> >> This series contains updates to e1000e, ixgbevf and igb.
> >  ...
> >>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next
> master
> >=20
> > Pulled, thanks a lot Jeff, and again welcome back.
>=20
> Jeff, please get this new warning fixed, thanks:
>=20
> drivers/net/ethernet/intel/i40e/i40e_ethtool.c: In function
> =E2=80=98i40e_del_fdir_entry=E2=80=99:
> drivers/net/ethernet/intel/i40e/i40e_ethtool.c:1441:18: warning:
> unused variable =E2=80=98pf=E2=80=99 [-Wunused-variable]
>   struct i40e_pf *pf =3D vsi->back;

Yeah, I noticed that as well.  I have a patch in my queue already to
resolve that, should be in my next pull request.  Thanks Dave!

--=-Cr+TOlFRv8hzev4Up2DJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJTG8AZAAoJEOVv75VaS+3OHuYP/3pnorI0d9Trdh52wCiCqjzW
+BbmZ5UCTP5Y9vpKF4XobCOosDqVBPFcVe3Ns04mLDz1nGqtWtHNbhiBb2zxAykG
EULsobMkzC0FXHpCbBKn2rJlMuY/ynEA+5PAl1KqeGlZJh4N9AsGoy6lseuPQU+n
OfRo4M4n4anXEAkLYsyi956I7q+L3iHK5lqB4yU63JFf145NknelmXB9vGa1EdDe
J2TZY8F5Q7KwMX1kY1bOb40gX0EEIq6HA2L0/EqKZq6fUNNp5RD4sLaZKDj07V/Z
Xhcvy4zSK2OywwLJVZYHLIeS3piuEvwWiSV188pp9dAq2dDKmPTMjtAhcUDAI8yE
QVY21ytGI8r7C+clro4iMsfypecuRsKMBsxrx5shgFLPWSvYJU8+jMOU2J7btZKP
ZkIVKEgvVyIXaOLNP0SQfUJpu9PlfA9I6ggdQrQ3zjzmtL7T8n2Fj+cEPASenG/0
AKHZB4LqWO26i5faDuvO55m1lg6/C/T60vwzxOnuM5H/E/0AlFzVQ15ROVDfpXn5
n6/l6RH1J+hWijO1jXYChsU10fz+JEj2o4zD9m61go5hLu1neYIJuHWyhPt4kgFZ
d+7OVcGqkXyWrmQaXhehxcuRlNTgeVkWEfGlog1VFWNRX44eZ754DTs1rsRKlzNa
8HIGkIw1zfRA3+XyPmcW
=gZzB
-----END PGP SIGNATURE-----

--=-Cr+TOlFRv8hzev4Up2DJ--
