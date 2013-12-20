From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [PATCH 1/2] netxen: Correct off-by-one error in bounds check
Date: Fri, 20 Dec 2013 15:11:28 +1100
Message-ID: <20131220041128.GB15958@voom.redhat.com>
References: <1387257753-18676-1-git-send-email-david@gibson.dropbear.id.au>
 <1387257753-18676-2-git-send-email-david@gibson.dropbear.id.au>
 <31AFFC7280259C4184970ABA9AFE8B938CF86A62@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="qcHopEYAB45HaUaB"
Cc: Sony Chacko <sony.chacko@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	"snagarka@redhat.com" <snagarka@redhat.com>,
	"tcamuso@redhat.com" <tcamuso@redhat.com>,
	"vdasgupt@redhat.com" <vdasgupt@redhat.com>
To: Manish Chopra <manish.chopra@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:32931 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752201Ab3LTFqJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Dec 2013 00:46:09 -0500
Content-Disposition: inline
In-Reply-To: <31AFFC7280259C4184970ABA9AFE8B938CF86A62@avmb3.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--qcHopEYAB45HaUaB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Dec 19, 2013 at 11:51:37AM +0000, Manish Chopra wrote:
> >-----Original Message-----
> >From: David Gibson [mailto:david@gibson.dropbear.id.au]
> >Sent: Tuesday, December 17, 2013 10:53 AM
> >To: Manish Chopra; Sony Chacko; Rajesh Borundia
> >Cc: netdev; snagarka@redhat.com; tcamuso@redhat.com;
> >vdasgupt@redhat.com; David Gibson
> >Subject: [PATCH 1/2] netxen: Correct off-by-one error in bounds check
> >
> >After retrieving an Rx buffer index from the hardware, the netxen driver=
 bounds
> >checks it against its array of receive buffers.  However in the case of =
LRO packets,
> >there's an off-by-one error in the check - it uses > instead of the >=3D=
 it uses for the
> >normal receive path in netxen_process_rcv().
> >
> >Signed-off-by: David Gibson <david@gibson.dropbear.id.au>
>=20
> Acked-by: Manish Chopra <manish.chopra@qlogic.com>
>=20
> Thanks David. This is really a bug fix. You can re-submit this single pat=
ch.

Ok, I added the extra fix Jiten suggested and resent.

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--qcHopEYAB45HaUaB
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAEBAgAGBQJSs8NwAAoJEGw4ysog2bOSYPQQANWI1QTVdN5TkLjTX6YHRt6r
LmKyhQTXli5WuTu3i6A8ixEan054JiUqMhwbN9uz5+NVLkCqI0Cuko4i3aMHhqv4
ZpL67Dlp/vwWqt28XHGbvjjapSjj7lN8rP3KWSwzTC2qokTkvfA5bhUXk0YA9XVk
0mJlU4Fh69keJjb0o7tinFJ+VjIyZyk9cgjVa/1VD/xwSyQVqQAeZrlko7I5M6br
EMY8mwlccPdtYS3JzIURw5ecUDmWiNvLH8OyKtkRLXqHt/RkguNGpUC4yt1Zfovl
lNFMfVXtlu8rtzOxgNjzrWPpm0thJTGWcPVIHC1I4uN56VwOuwWPVxLuSFrwCmPY
OgN81vvPvmmFvQSKIqdAa21u6ZJAaaK8kbm1EqhMWkTrQD9p1VDb8HfhL+1BZ6I0
N/rHzx2G/hAucFvZueGN+ep9PHjxUU6eVDbp+HWJlsRABA41HajVybEwiO/vKUmF
/Ys4C/5jXQ5YysFlSo6SVVAHvnaJOgQUL+GCYBON6YfakrkJCsABvKlm+3l0JWA1
Fh7HLISKhJkuKTUeoqdfOopFgDJa5IopuhbhxuA966vtJxx73Iz77l8LnTKrKYCD
+GpdMYxXqArm8ru0AKxwvmbGXnxUAOS6chzjmwVTT9uL9UEaxRoZh55EtxyhQGYp
NrDFjN1R6XHfGWVui2Hv
=Bzdg
-----END PGP SIGNATURE-----

--qcHopEYAB45HaUaB--
