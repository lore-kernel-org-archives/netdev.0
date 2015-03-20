From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next v2 1/3] switchdev: add swdev ops
Date: Fri, 20 Mar 2015 23:00:53 +0000
Message-ID: <1426892453.32382.12.camel@decadent.org.uk>
References: <1426470321-48669-1-git-send-email-sfeldma@gmail.com>
	 <1426470321-48669-2-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-2I91sybGqqYD11EAlP52"
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	roopa@cumulusnetworks.com, simon.horman@netronome.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:50093 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751426AbbCTXBB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 19:01:01 -0400
In-Reply-To: <1426470321-48669-2-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-2I91sybGqqYD11EAlP52
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2015-03-15 at 18:45 -0700, sfeldma@gmail.com wrote:
[...]
> +/**
> + * struct switchdev_ops - switchdev operations
> + *
> + * int (*swdev_parent_id_get)(struct net_device *dev,
> + *			      struct netdev_phys_item_id *psid);
> + *	Called to get an ID of the switch chip this port is part of.
> + *	If driver implements this, it indicates that it represents a port
> + *	of a switch chip.
> + *
> + * int (*swdev_port_stp_update)(struct net_device *dev, u8 state);
> + *	Called to notify switch device port of bridge port STP
> + *	state change.
> + *
> + * int (*swdev_fib_ipv4_add)(struct net_device *dev, __be32 dst,
> + *			     int dst_len, struct fib_info *fi,
> + *			     u8 tos, u8 type, u32 nlflags, u32 tb_id);
> + *	Called to add/modify IPv4 route to switch device.
> + *
> + * int (*swdev_fib_ipv4_del)(struct net_device *dev, __be32 dst,
> + *			     int dst_len, struct fib_info *fi,
> + *			     u8 tos, u8 type, u32 tb_id);
> + *	Called to delete IPv4 route from switch device.
[...]

This isn't correct kernel-doc syntax.

Ben.

--=20
Ben Hutchings
All extremists should be taken out and shot.

--=-2I91sybGqqYD11EAlP52
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVQympee/yOyVhhEJAQr4DxAAzJIXL0MsPItPVqdwv2heLm1DkpyY7sSs
maCwybQ0r9oCFH1BbfCuYzv3ZZ18ny0cvPSvfDsypH461NxyMZBxT78LnGwX8zXB
QNzDIOxjjtWqkoFKPvbnp5NhNUzHkY38mIZ1GvlOEQgNx6TmKAUanjX1tf2PEUXp
1XGhQ/cBSgzdLtLCHxBbjOxAQYvBABcsIp+RE8mwyDqsNtUTD2YLnkrT/ZFbohUB
QWB8exBA5IWDPHtZ7C/XhGmmaYLQnbAOtEvtA+gp5s/l/GOVjuhwebHXVudwkSnK
KpQ7w/jf63aseN/yfSWvhr4n1wOWJpWCmnCh5d69d1r/kCHAmcYyIcF5Zu6OPZ+g
XaiXERrzzEWo0kXiRdZuEzy5T9P2Az5GB5vc1Bn7nFA42wvBmrB08zoz3m+tt/7j
vMncL+JkEOb9WF+s3/DS3TSlyXMJwuaWkhCaHrzuKXDJu/PqhO6XqzCpcv+yUoMc
9O33hiG8RDp3MnANgR3h+j+UD5A2RHH3RQI4fwKG4oH+3OTBOna6+AvwKwgszDRJ
TMw3bCeC4ICLoZZ1zfoNUA64/bnMFyrL34SK21u6k58TsgCf5b6OUGFVGoKhTllm
255uYzvH/aioNGZX2GLCV/60CklvEX5T/Ce0dAu5MEjv8EFH13EjUTDWhZra2vSK
liWNdTuLGd0=
=pdfR
-----END PGP SIGNATURE-----

--=-2I91sybGqqYD11EAlP52--
