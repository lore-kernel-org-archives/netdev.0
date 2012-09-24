From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH linux-firmware 1/1] bnx2x: update fw to 7.8.2
Date: Mon, 24 Sep 2012 20:37:38 +0100
Message-ID: <20120924193737.GI29217@decadent.org.uk>
References: <1348471509-16658-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="KDt/GgjP6HVcx58l"
Cc: dwmw2@infradead.org, netdev@vger.kernel.org,
	Ariel Elior <ariele@broadcom.com>,
	Eilon Goldstein <eilong@broadcom.com>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:50881 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757869Ab2IXThl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 15:37:41 -0400
Content-Disposition: inline
In-Reply-To: <1348471509-16658-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--KDt/GgjP6HVcx58l
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Sep 24, 2012 at 09:25:09AM +0200, Yuval Mintz wrote:
> This new firmware fixes several minor bugs:
>  1. In switch dependent mode, DCB priority was used to override inner vlan
>     priority.
>  2. In switch dependent  mode, inner vlan was added in case of DCB priori=
ty
>     even if outer vlan was present.
>  3. In switch dependent mode, outer vlan was overridden by DCB priority w=
hen
>     working in STATIC COS mode while inner vlan was present.
>  4. iSCSI - under heavy iSCSI traffic, when TCP out-of-order condition
>     occurred, it was possible for the connection to close and recover.
>  5. iSCSI - connections on-chip TCP establishment might have failed.
>  6. iSCSI - out-of-order isles might have caused on-chip TCP connections
>     to fail in their graceful termination.
>  7. iSCSI - there was a theoretical race in which an RST packet sent from
>     pure-ack queue in specific timing could cause a credit-return overflo=
w.
>  8. iSCSI - not all packets were completed on a forward channel.
>  9. DCB - fixed for 4-port devices; Until now, wrong credit counters were
>     used, causing dcb to fail.
> 10. Fixed false parity reported in CAM memories when operating near -5% on
>     the 1.0V core supply.
> 11. ETS default settings are set to fairness between traffic classes (rat=
her
>     than strict priority), and uses the same chip receive buffer configur=
ation
>     for both PFC and pause.
>=20
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Ariel Elior <ariele@broadcom.com>
> Signed-off-by: Eilon Goldstein <eilong@broadcom.com>
> ---
> Please consider adding this new FW into the FW tree.
[...]

Applied, thanks.

Ben.

--=20
Ben Hutchings
We get into the habit of living before acquiring the habit of thinking.
                                                              - Albert Camus

--KDt/GgjP6HVcx58l
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUBUGC2gOe/yOyVhhEJAQq52w//RtqTGH4AM43XlfgFkiFCcG8kLSeaXMBB
Qa4l/Yseo6wgKwi8k/yMBZ2/daYO4Efy9tfNmuxdIRF1HYtEHObyjPacmZLrJBG7
FP8NE2mXbhf1hSHAh2h8P8Kwsdjah7uMtd2DbAVhzi+EEfVd6G5IbQqr4ysJ7thQ
R8QJtohp+OP+Uy3hes+M/t5NhTG2ADB6spTEqJIrvjnzrLl8TzTaL1U3dkpmJn5Y
KOGSUaMCvkLbYKzVj2WZmSmUubGKLDmbWja6vUAzJGX0d4XZN5IZ3S5Dt9iWLBw+
pDzS4phyViBpqfufitMyzOZBJ/yCsCfedW0zumKAxcBVQUjoaO5y2QU3sAFdII/y
2nsGuiLjO15Gi9Tn6PaRkhAI9ycTHNUh3RPbx4iXT9iMZzaow1hP8PdF28ezogw1
A4poWA5FrTf8SMrvkGfTpsa107KTQF/rjDlGEbhRYdbNtyLBRBQZWo/w2FGBSc3y
pPrMSxbkXmm059kvWKpkTL7hgM6ROMe8TTlkt5Eh+CiYjesKxb+R3Qvvmt4L5Fac
SIslLsHD4O/i5vS9axKG+1MkKwqSWdtbgByEu7+t8I1PcSWLlq5q+OrWSYLJ4oNt
TN8gZ/ukGUtLYUViLgHMrYZW1DZ++XIuhEbfzxdhqvqfcJJiUjN8mxzEyA5a+RJ4
MMRe4U1+UdE=
=udBD
-----END PGP SIGNATURE-----

--KDt/GgjP6HVcx58l--
