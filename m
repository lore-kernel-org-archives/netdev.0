From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Problem authenticating using WPA with bcm43xx-softmac
Date: Fri, 09 Jun 2006 13:44:53 +0200
Message-ID: <1149853494.3864.6.camel@johannes.berg>
References: <4485D66B.7080108@lwfinger.net>
	 <1149682213.3999.14.camel@johannes> <4486F513.5050906@lwfinger.net>
	 <1149695470.3925.7.camel@johannes> <1149695859.3925.11.camel@johannes>
	 <1149701352.2625.20.camel@localhost.localdomain>
	 <44871723.3040803@lwfinger.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-47DafaDK0e5KEx5doMBp"
Cc: Dan Williams <dcbw@redhat.com>, netdev@vger.kernel.org,
	Jouni Malinen <jkm@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:58835 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S965233AbWFILpY
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jun 2006 07:45:24 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <44871723.3040803@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-47DafaDK0e5KEx5doMBp
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2006-06-07 at 13:12 -0500, Larry Finger wrote:
> > (ie, add the "hh" before the x to tell the print that it's a char)
> >=20
> That doesn't work - the result is
>=20
> %hx%hx%hx%hx%hx%hx%hx%hx%hx%hx%hx%hx%hx%hx%hx%hx%hx%hx%hx%hx%hx%hx%hx%hx

Looks like the kernel doesn't support that modifier.

> I changed the line to cast the output byte as a u8 as follows:
>=20
>                          dprintk("%.2x", (u8)mac->wpa.IE[i]);
>=20
> This produces the line
>=20
> generic IE set to dd160050f20101000050f20201000050f20201000050f202
>=20
> This is the WPA IE supplied by wpa_supplicant and it matches the one used=
 in the ndiswrapper case.=20
> One mystery solved,=20

Yeah good :)

> but why doesn't it work?

No idea. If we had a dump maybe we could tell :/

> Johannes - should I submit the patch to fix this printout, or would you l=
ike to do it?

Please do.

johannes

--=-47DafaDK0e5KEx5doMBp
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIVAwUARIlfM6Vg1VMiehFYAQISaRAAhKPGA+l5CP8tKDUBlf1gWCGyYvDIwdp4
Eg2PaehxEkeriAVmriCSGBgFTW/fdQTf/SurTIn/A2b8Fg5MUc8eqD5OMmo0tU10
NdZeepZEKmgWQixuZxHi80Q9Azz1YEMDxYu6vbpI1AEouXq54ZKQVKIUMO9ZFpFt
gkKMUsVrmRgHnuOrVlFtY+EcUdhTt2xmjX1nY0O3kzaFRb9sL8cHp3/PNbG1nnh2
3Sv+W8E+k1jfBKSAHBBT7QfRfriCord/6ltRH/c6JuomEOzqu+W0NSCDoKAjQUoq
Y/4hIr9M7vROuH1hRJEajgyLMr/aJqzjQCIojxqbugKD6tOj0L/mgCHVfHnyCHhT
ye+GFjf/nOxftFNAJmnG1Kf3DijPy/+EBYOGE48GKvjcZ1HY1pPevsEilkBrNo6m
nX8UActjEEGgF45OCEAUyK0GKhHBCq0/zgpg6g3xzTY2Fl0B92Z2W2Y6zPR7m5/e
KfIC0abb63iysICT8vSNDAolSrruW+DOjOu0A8fFoRPgowmknLTvxkUZvQxBAMzk
iyydl5agGfnTbDA2/fL1SeLQBTAG5eI42Do78n1cmT/STOm1PmP0ldNRypAHUXoR
2iJKjvF578qolM0m3mrTeJ9g/yKfKUAEtyektp4SnSyy8RHGYVVUj5wcONZtnor4
EuvwvWH4zYA=
=DEt2
-----END PGP SIGNATURE-----

--=-47DafaDK0e5KEx5doMBp--

