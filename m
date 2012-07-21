From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 4/6] e1000: configure and read MDI settings
Date: Sat, 21 Jul 2012 10:37:04 -0700
Message-ID: <1342892224.2135.2.camel@jtkirshe-mobl>
References: <1342820631-19738-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1342820631-19738-5-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1342826859.11373.123.camel@deadeye.wl.decadent.org.uk>
	 <alpine.WNT.2.00.1207201807470.14524@jbrandeb-mobl2.amr.corp.intel.com>
	 <1342885066.11373.126.camel@deadeye.wl.decadent.org.uk>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-qwHkmYxiZeLBlU+sMqlw"
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com, Tushar Dave <tushar.n.dave@intel.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:7487 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751185Ab2GURhQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Jul 2012 13:37:16 -0400
In-Reply-To: <1342885066.11373.126.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-qwHkmYxiZeLBlU+sMqlw
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2012-07-21 at 16:37 +0100, Ben Hutchings wrote:
>=20
> On Fri, 2012-07-20 at 18:17 -0700, Brandeburg, Jesse wrote:
> >=20
> > On Fri, 20 Jul 2012, Ben Hutchings wrote:
> > > Why don't you set ecmd->eth_tp_mdix_ctrl here?
> > >=20
> > > If you also leave it as 0, it's impossible for userland to tell
> whether
> > > the current mode was forced or automatically selected.
> >=20
> > Thanks for the review, right now the get interface (and ethtool
> display)=20
> > doesn't support any way to report if the setting was forced or not.
> I=20
> > didn't think about changing the get because I didn't want to modify
> the=20
> > userland reporting (I also figured it was a simple interface right
> now,=20
> > and didn't need changing, and was focused on the _set_ which is the
> part=20
> > fixing the users' reported bugs.)
>=20
> Everything else you can change with ETHTOOL_SSET is also reported by
> ETHTOOL_GSET; why would this be any different?
>=20
> > I think the patches as they currently stand are okay, do you agree?
> I=20
> > would be glad to submit a followon to implement the new "get"
> interface if=20
> > we can hash out the interface changes, but I see no reason to gate
> these=20
> > patches.
>=20
> You left this for 20 months, what's the hurry now?=20

Since there some changes that are needed in this patch set, I will drop
this series from my tree so that I can continue pushing additional
ixgbe/ixgbevf patches.

--=-qwHkmYxiZeLBlU+sMqlw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQCujAAAoJEOVv75VaS+3OYGcP/1H62uikk5gNDoO0Un32mGeh
5CjF7407JzXO8cI3mIhKycx2yWyhm2cDCzy2UENIUrqIhrbJnqZQh4i+LMVEOqgP
FLb1X2Bhwu4HTsfm2DW7W6FfuPw1T/CploWl/4BPVOt8WVV0qWjLki8n3J6WNa9B
ChdrRoGa9yZ9R4T1Cqi1HZYmCfjgOVwG5iLamr3JwJekpe/c4gnxFGAqTKOqg5Rt
Qy6+dxs8WiwhoDtxyCzxKnhh6XCrq+i2D01BdAlDTR9W4fWIxv0ERE12rq6zMGYv
mkYBXJlN372hpSySD8G06S/ci923fwjU/OTL27EuZ8Jq6tJFLByKGDQ3rxIwSotc
+KKfMmr6D7Bc4QUFktxUv1HkX0opXTIEGz0MwN3cANiUB1RT4fJKPq0jUrUKbNcq
VjCuayS2JEMyDffI+JJLieuvG+FdI+AgZ+yNRsK+xUgSNA+rLJvmkoMSM3c9HBfg
uRcj+7qjzAD/DuFUXs2eQAMJSV6Jsac0ZOD3YhC1BUYq3rEyWRCjyF40VC8ek1dK
sR/Unn0h2tlPcQQmHe7+BydERs7d+HCpCET3sWB7n5g0blXuCzESoHE9ejOCrHAm
dC6dtPS+8PB3Zl4OajGL20dxcQR3/1PmMl0jXTk6p1SMMIFRVZ6c80LiB5Ry5Cof
2R3Hl3u82oeh171GpyVC
=dh6Z
-----END PGP SIGNATURE-----

--=-qwHkmYxiZeLBlU+sMqlw--
